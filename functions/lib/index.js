"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createWorker = void 0;
const app_1 = require("firebase-admin/app");
const auth_1 = require("firebase-admin/auth");
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const firebase_functions_1 = require("firebase-functions");
(0, app_1.initializeApp)();
const db = (0, firestore_1.getFirestore)();
const auth = (0, auth_1.getAuth)();
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
