"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateWorkshopUserStatus = exports.createWorker = void 0;
const app_1 = require("firebase-admin/app");
const auth_1 = require("firebase-admin/auth");
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const firebase_functions_1 = require("firebase-functions");
(0, app_1.initializeApp)();
const db = (0, firestore_1.getFirestore)();
const auth = (0, auth_1.getAuth)();
const allowedStatuses = new Set([
    "active",
    "suspended",
    "removed",
]);
const userManagementPermissions = {
    active: "usersUpdate",
    suspended: "usersSuspend",
    removed: "usersRemove",
};
async function getWorkshopUserForCaller(callerUid, workshopId) {
    const snapshot = await db
        .collection("workshop_users")
        .where("userId", "==", callerUid)
        .where("workshopId", "==", workshopId)
        .limit(1)
        .get();
    if (snapshot.empty) {
        return null;
    }
    return snapshot.docs[0].data();
}
async function callerHasWorkshopPermission(callerUid, workshopId, permission) {
    const workshopSnapshot = await db
        .collection("workshops")
        .doc(workshopId)
        .get();
    if (!workshopSnapshot.exists) {
        return false;
    }
    const workshop = workshopSnapshot.data();
    if (!workshop) {
        return false;
    }
    if (workshop.ownerId === callerUid) {
        return true;
    }
    const membership = await getWorkshopUserForCaller(callerUid, workshopId);
    if (!membership) {
        return false;
    }
    if (membership.status !== "active") {
        return false;
    }
    const roleId = membership.roleId;
    if (typeof roleId !== "string" || roleId.length === 0) {
        return false;
    }
    const roleSnapshot = await db
        .collection("roles")
        .doc(roleId)
        .get();
    if (!roleSnapshot.exists) {
        return false;
    }
    const role = roleSnapshot.data();
    if (!role) {
        return false;
    }
    const permissions = role.permissions;
    if (!Array.isArray(permissions)) {
        return false;
    }
    return permissions.includes(permission);
}
exports.createWorker = (0, https_1.onCall)({
    region: "africa-south1",
}, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Authentication is required.");
    }
    const data = request.data;
    const displayName = typeof data.displayName === "string"
        ? data.displayName.trim()
        : "";
    const phone = typeof data.phone === "string"
        ? data.phone.trim()
        : "";
    const password = typeof data.password === "string"
        ? data.password
        : "";
    const roleId = typeof data.roleId === "string"
        ? data.roleId.trim()
        : "";
    const workshopId = typeof data.workshopId === "string"
        ? data.workshopId.trim()
        : "";
    if (!displayName) {
        throw new https_1.HttpsError("invalid-argument", "Worker display name is required.");
    }
    if (!phone) {
        throw new https_1.HttpsError("invalid-argument", "Worker phone is required.");
    }
    if (password.length < 6) {
        throw new https_1.HttpsError("invalid-argument", "Worker password must contain at least 6 characters.");
    }
    if (!roleId) {
        throw new https_1.HttpsError("invalid-argument", "Role is required.");
    }
    if (!workshopId) {
        throw new https_1.HttpsError("invalid-argument", "Workshop is required.");
    }
    const ownerId = request.auth.uid;
    const workshopSnapshot = await db
        .collection("workshops")
        .doc(workshopId)
        .get();
    if (!workshopSnapshot.exists) {
        throw new https_1.HttpsError("not-found", "Workshop was not found.");
    }
    const workshop = workshopSnapshot.data();
    if (!workshop || workshop.ownerId !== ownerId) {
        throw new https_1.HttpsError("permission-denied", "Only the workshop owner can create workers.");
    }
    const roleSnapshot = await db
        .collection("roles")
        .doc(roleId)
        .get();
    if (!roleSnapshot.exists) {
        throw new https_1.HttpsError("not-found", "Role was not found.");
    }
    const role = roleSnapshot.data();
    if (!role || role.workshopId !== workshopId) {
        throw new https_1.HttpsError("permission-denied", "Role does not belong to this workshop.");
    }
    const workerLoginId = `WK-${Math.random()
        .toString(36)
        .substring(2, 10)
        .toUpperCase()}`;
    const workerEmail = `${workerLoginId.toLowerCase()}@workers.kitchenflow.app`;
    let workerUid = null;
    try {
        const userRecord = await auth.createUser({
            email: workerEmail,
            password,
            displayName,
        });
        workerUid = userRecord.uid;
        const workshopUserRef = db
            .collection("workshop_users")
            .doc();
        await workshopUserRef.set({
            workshopId,
            userId: userRecord.uid,
            workerId: userRecord.uid,
            workerLoginId,
            roleId,
            status: "active",
            phone,
            displayName,
            createdBy: ownerId,
            joinedAt: firestore_1.FieldValue.serverTimestamp(),
        });
        firebase_functions_1.logger.info("Worker created successfully.", {
            workerId: userRecord.uid,
            workerLoginId,
            workshopId,
            createdBy: ownerId,
        });
        return {
            workerId: userRecord.uid,
            workerLoginId,
            temporaryPassword: password,
            workshopUserId: workshopUserRef.id,
        };
    }
    catch (error) {
        firebase_functions_1.logger.error("Worker creation failed.", error);
        if (workerUid !== null) {
            try {
                await auth.deleteUser(workerUid);
            }
            catch (rollbackError) {
                firebase_functions_1.logger.error("Worker rollback failed.", rollbackError);
            }
        }
        throw new https_1.HttpsError("internal", "Failed to create worker.");
    }
});
exports.updateWorkshopUserStatus = (0, https_1.onCall)({
    region: "africa-south1",
}, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Authentication is required.");
    }
    const data = request.data;
    const workshopUserId = typeof data.workshopUserId === "string"
        ? data.workshopUserId.trim()
        : "";
    const workshopId = typeof data.workshopId === "string"
        ? data.workshopId.trim()
        : "";
    const status = data.status;
    if (!workshopUserId) {
        throw new https_1.HttpsError("invalid-argument", "Workshop user ID is required.");
    }
    if (!workshopId) {
        throw new https_1.HttpsError("invalid-argument", "Workshop ID is required.");
    }
    if (typeof status !== "string" ||
        !allowedStatuses.has(status)) {
        throw new https_1.HttpsError("invalid-argument", "Invalid workshop user status.");
    }
    const callerUid = request.auth.uid;
    const hasPermission = await callerHasWorkshopPermission(callerUid, workshopId, userManagementPermissions[status]);
    if (!hasPermission) {
        throw new https_1.HttpsError("permission-denied", "You do not have permission to update workshop users.");
    }
    const workshopUserRef = db
        .collection("workshop_users")
        .doc(workshopUserId);
    const workshopUserSnapshot = await workshopUserRef.get();
    if (!workshopUserSnapshot.exists) {
        throw new https_1.HttpsError("not-found", "Workshop user was not found.");
    }
    const workshopUser = workshopUserSnapshot.data();
    if (!workshopUser ||
        workshopUser.workshopId !== workshopId) {
        throw new https_1.HttpsError("permission-denied", "Workshop user does not belong to this workshop.");
    }
    await workshopUserRef.update({
        status,
        updatedAt: firestore_1.FieldValue.serverTimestamp(),
        updatedBy: callerUid,
    });
    firebase_functions_1.logger.info("Workshop user status updated.", {
        workshopUserId,
        workshopId,
        status,
        updatedBy: callerUid,
    });
    return {
        success: true,
        workshopUserId,
        status,
    };
});
