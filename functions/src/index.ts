import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import {
  getFirestore,
  FieldValue,
} from "firebase-admin/firestore";
import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";
import { logger } from "firebase-functions";

initializeApp();

const db = getFirestore();
const auth = getAuth();

interface CreateWorkerData {
  displayName: string;
  phone: string;
  password: string;
  roleId: string;
  workshopId: string;
}

interface UpdateWorkshopUserStatusData {
  workshopUserId: string;
  status: string;
}

export const createWorker = onCall(
  {
    region: "africa-south1",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Authentication is required.",
      );
    }

    const data = request.data as CreateWorkerData;

    const displayName =
      typeof data.displayName === "string"
        ? data.displayName.trim()
        : "";

    const phone =
      typeof data.phone === "string"
        ? data.phone.trim()
        : "";

    const password =
      typeof data.password === "string"
        ? data.password
        : "";

    const roleId =
      typeof data.roleId === "string"
        ? data.roleId.trim()
        : "";

    const workshopId =
      typeof data.workshopId === "string"
        ? data.workshopId.trim()
        : "";

    if (!displayName) {
      throw new HttpsError(
        "invalid-argument",
        "Worker display name is required.",
      );
    }

    if (!phone) {
      throw new HttpsError(
        "invalid-argument",
        "Worker phone is required.",
      );
    }

    if (password.length < 6) {
      throw new HttpsError(
        "invalid-argument",
        "Worker password must contain at least 6 characters.",
      );
    }

    if (!roleId) {
      throw new HttpsError(
        "invalid-argument",
        "Role is required.",
      );
    }

    if (!workshopId) {
      throw new HttpsError(
        "invalid-argument",
        "Workshop is required.",
      );
    }

    const ownerId = request.auth.uid;

    const workshopSnapshot = await db
      .collection("workshops")
      .doc(workshopId)
      .get();

    if (!workshopSnapshot.exists) {
      throw new HttpsError(
        "not-found",
        "Workshop was not found.",
      );
    }

    const workshop = workshopSnapshot.data();

    if (!workshop || workshop.ownerId !== ownerId) {
      throw new HttpsError(
        "permission-denied",
        "Only the workshop owner can create workers.",
      );
    }

    const roleSnapshot = await db
      .collection("roles")
      .doc(roleId)
      .get();

    if (!roleSnapshot.exists) {
      throw new HttpsError(
        "not-found",
        "Role was not found.",
      );
    }

    const role = roleSnapshot.data();

    if (!role || role.workshopId !== workshopId) {
      throw new HttpsError(
        "permission-denied",
        "Role does not belong to this workshop.",
      );
    }

    const workerLoginId =
      `WK-${Math.random()
        .toString(36)
        .substring(2, 10)
        .toUpperCase()}`;

    const workerEmail =
      `${workerLoginId.toLowerCase()}@workers.kitchenflow.app`;

    let workerUid: string | null = null;

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
        joinedAt: FieldValue.serverTimestamp(),
      });

      logger.info(
        "Worker created successfully.",
        {
          workerId: userRecord.uid,
          workerLoginId,
          workshopId,
          createdBy: ownerId,
        },
      );

      return {
        workerId: userRecord.uid,
        workerLoginId,
        temporaryPassword: password,
        workshopUserId: workshopUserRef.id,
      };
    } catch (error) {
      logger.error(
        "Worker creation failed.",
        error,
      );

      if (workerUid !== null) {
        try {
          await auth.deleteUser(workerUid);
        } catch (rollbackError) {
          logger.error(
            "Worker rollback failed.",
            rollbackError,
          );
        }
      }

      throw new HttpsError(
        "internal",
        "Failed to create worker.",
      );
    }
  },
);

export const updateWorkshopUserStatus = onCall(
  {
    region: "africa-south1",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Authentication is required.",
      );
    }

    const data =
      request.data as UpdateWorkshopUserStatusData;

    const workshopUserId =
      typeof data.workshopUserId === "string"
        ? data.workshopUserId.trim()
        : "";

    const status =
      typeof data.status === "string"
        ? data.status.trim()
        : "";

    if (!workshopUserId) {
      throw new HttpsError(
        "invalid-argument",
        "Workshop user id is required.",
      );
    }

    const allowedStatuses = [
      "pending",
      "active",
      "suspended",
      "removed",
    ];

    if (!allowedStatuses.includes(status)) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid workshop member status.",
      );
    }

    const ownerId = request.auth.uid;

    const workshopUserRef = db
      .collection("workshop_users")
      .doc(workshopUserId);

    const workshopUserSnapshot =
      await workshopUserRef.get();

    if (!workshopUserSnapshot.exists) {
      throw new HttpsError(
        "not-found",
        "Workshop user was not found.",
      );
    }

    const workshopUser =
      workshopUserSnapshot.data();

    if (!workshopUser) {
      throw new HttpsError(
        "not-found",
        "Workshop user data was not found.",
      );
    }

    const workshopId =
      typeof workshopUser.workshopId === "string"
        ? workshopUser.workshopId
        : "";

    if (!workshopId) {
      throw new HttpsError(
        "failed-precondition",
        "Workshop user has no workshop.",
      );
    }

    const workshopSnapshot = await db
      .collection("workshops")
      .doc(workshopId)
      .get();

    if (!workshopSnapshot.exists) {
      throw new HttpsError(
        "not-found",
        "Workshop was not found.",
      );
    }

    const workshop = workshopSnapshot.data();

    if (!workshop || workshop.ownerId !== ownerId) {
      throw new HttpsError(
        "permission-denied",
        "Only the workshop owner can change member status.",
      );
    }

    await workshopUserRef.update({
      status,
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: ownerId,
    });

    const updatedSnapshot =
      await workshopUserRef.get();

    const updatedData =
      updatedSnapshot.data();

    if (!updatedData) {
      throw new HttpsError(
        "internal",
        "Updated workshop user could not be read.",
      );
    }

    return {
      workshopUser: {
        ...updatedData,
        id: workshopUserRef.id,
      },
    };
  },
);