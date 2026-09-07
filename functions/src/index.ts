import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import {
  FieldValue,
  getFirestore,
} from "firebase-admin/firestore";
import {
  HttpsError,
  onCall,
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
  status: "active" | "suspended" | "removed";
  workshopId: string;
}

interface CreateRoleData {
  workshopId: string;
  name: string;
  description: string;
  permissions: string[];
  isSystemRole: boolean;
  createdAt: string;
  updatedAt: string;
}

interface UpdateRoleData extends CreateRoleData {
  roleId: string;
}

interface DeleteRoleData {
  workshopId: string;
  roleId: string;
}

const allowedStatuses = new Set([
  "active",
  "suspended",
  "removed",
]);

const userManagementPermissions = {
  active: "usersUpdate",
  suspended: "usersSuspend",
  removed: "usersRemove",
} as const;

async function getWorkshopUserForCaller(
  callerUid: string,
  workshopId: string,
) {
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

async function callerHasWorkshopPermission(
  callerUid: string,
  workshopId: string,
  permission: string,
): Promise<boolean> {
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

  const membership = await getWorkshopUserForCaller(
    callerUid,
    workshopId,
  );

  if (!membership) {
    return false;
  }

  if (membership.status !== "active") {
    return false;
  }

  const roleId = membership.roleId;

  if (
    typeof roleId !== "string" ||
    roleId.length === 0
  ) {
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

  if (role.workshopId !== workshopId) {
    return false;
  }

  const permissions = role.permissions;

  if (!Array.isArray(permissions)) {
    return false;
  }

  return permissions.includes(permission);
}

async function requireWorkshopPermission(
  callerUid: string,
  workshopId: string,
  permission: string,
): Promise<void> {
  const hasPermission =
    await callerHasWorkshopPermission(
      callerUid,
      workshopId,
      permission,
    );

  if (!hasPermission) {
    throw new HttpsError(
      "permission-denied",
      "You do not have permission to perform this operation.",
    );
  }
}

function validateRolePermissions(
  permissions: unknown,
): string[] {
  if (!Array.isArray(permissions)) {
    throw new HttpsError(
      "invalid-argument",
      "Role permissions must be an array.",
    );
  }

  const normalizedPermissions = permissions
    .filter(
      (permission): permission is string =>
        typeof permission === "string",
    )
    .map((permission) => permission.trim())
    .filter((permission) => permission.length > 0);

  if (
    normalizedPermissions.length !==
    permissions.length
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Role permissions contain invalid values.",
    );
  }

  return [...new Set(normalizedPermissions)];
}

async function getRoleForWorkshop(
  roleId: string,
  workshopId: string,
) {
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

  if (!role) {
    throw new HttpsError(
      "not-found",
      "Role was not found.",
    );
  }

  if (role.workshopId !== workshopId) {
    throw new HttpsError(
      "permission-denied",
      "Role does not belong to this workshop.",
    );
  }

  return {
    snapshot: roleSnapshot,
    data: role,
  };
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

    if (
      !role ||
      role.workshopId !== workshopId
    ) {
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

    const workshopId =
      typeof data.workshopId === "string"
        ? data.workshopId.trim()
        : "";

    const status = data.status;

    if (!workshopUserId) {
      throw new HttpsError(
        "invalid-argument",
        "Workshop user ID is required.",
      );
    }

    if (!workshopId) {
      throw new HttpsError(
        "invalid-argument",
        "Workshop ID is required.",
      );
    }

    if (
      typeof status !== "string" ||
      !allowedStatuses.has(status)
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid workshop user status.",
      );
    }

    const callerUid = request.auth.uid;

    await requireWorkshopPermission(
      callerUid,
      workshopId,
      userManagementPermissions[status],
    );

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

    if (
      !workshopUser ||
      workshopUser.workshopId !== workshopId
    ) {
      throw new HttpsError(
        "permission-denied",
        "Workshop user does not belong to this workshop.",
      );
    }

    await workshopUserRef.update({
      status,
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: callerUid,
    });

    logger.info(
      "Workshop user status updated.",
      {
        workshopUserId,
        workshopId,
        status,
        updatedBy: callerUid,
      },
    );

    return {
      success: true,
      workshopUserId,
      status,
    };
  },
);

export const createRole = onCall(
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

    const data = request.data as CreateRoleData;

    const workshopId =
      typeof data.workshopId === "string"
        ? data.workshopId.trim()
        : "";

    const name =
      typeof data.name === "string"
        ? data.name.trim()
        : "";

    const description =
      typeof data.description === "string"
        ? data.description.trim()
        : "";

    const permissions =
      validateRolePermissions(data.permissions);

    if (!workshopId) {
      throw new HttpsError(
        "invalid-argument",
        "Workshop ID is required.",
      );
    }

    if (!name) {
      throw new HttpsError(
        "invalid-argument",
        "Role name is required.",
      );
    }

    if (typeof data.isSystemRole !== "boolean") {
      throw new HttpsError(
        "invalid-argument",
        "isSystemRole must be a boolean.",
      );
    }

    if (data.isSystemRole) {
      throw new HttpsError(
        "permission-denied",
        "System roles cannot be created manually.",
      );
    }

    const callerUid = request.auth.uid;

    await requireWorkshopPermission(
      callerUid,
      workshopId,
      "rolesCreate",
    );

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

    const now = new Date().toISOString();

    const roleRef = db
      .collection("roles")
      .doc();

    await roleRef.set({
      name,
      description,
      workshopId,
      permissions,
      isSystemRole: false,
      createdAt:
        typeof data.createdAt === "string" &&
        data.createdAt.trim().length > 0
          ? data.createdAt
          : now,
      updatedAt:
        typeof data.updatedAt === "string" &&
        data.updatedAt.trim().length > 0
          ? data.updatedAt
          : now,
    });

    const createdSnapshot =
      await roleRef.get();

    const createdRole =
      createdSnapshot.data();

    if (!createdRole) {
      throw new HttpsError(
        "internal",
        "Role was created but could not be read.",
      );
    }

    logger.info(
      "Role created successfully.",
      {
        roleId: roleRef.id,
        workshopId,
        createdBy: callerUid,
      },
    );

    return {
      id: roleRef.id,
      ...createdRole,
    };
  },
);

export const updateRole = onCall(
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

    const data = request.data as UpdateRoleData;

    const roleId =
      typeof data.roleId === "string"
        ? data.roleId.trim()
        : "";

    const workshopId =
      typeof data.workshopId === "string"
        ? data.workshopId.trim()
        : "";

    const name =
      typeof data.name === "string"
        ? data.name.trim()
        : "";

    const description =
      typeof data.description === "string"
        ? data.description.trim()
        : "";

    const permissions =
      validateRolePermissions(data.permissions);

    if (!roleId) {
      throw new HttpsError(
        "invalid-argument",
        "Role ID is required.",
      );
    }

    if (!workshopId) {
      throw new HttpsError(
        "invalid-argument",
        "Workshop ID is required.",
      );
    }

    if (!name) {
      throw new HttpsError(
        "invalid-argument",
        "Role name is required.",
      );
    }

    if (typeof data.isSystemRole !== "boolean") {
      throw new HttpsError(
        "invalid-argument",
        "isSystemRole must be a boolean.",
      );
    }

    const callerUid = request.auth.uid;

    await requireWorkshopPermission(
      callerUid,
      workshopId,
      "rolesUpdate",
    );

    const role = await getRoleForWorkshop(
      roleId,
      workshopId,
    );

    if (role.data.isSystemRole === true) {
      throw new HttpsError(
        "permission-denied",
        "System roles cannot be modified.",
      );
    }

    const updatedAt =
      typeof data.updatedAt === "string" &&
      data.updatedAt.trim().length > 0
        ? data.updatedAt
        : new Date().toISOString();

    await db
      .collection("roles")
      .doc(roleId)
      .set({
        name,
        description,
        workshopId,
        permissions,
        isSystemRole: false,
        createdAt:
          typeof role.data.createdAt === "string"
            ? role.data.createdAt
            : new Date().toISOString(),
        updatedAt,
      });

    const updatedSnapshot =
      await db
        .collection("roles")
        .doc(roleId)
        .get();

    const updatedRole =
      updatedSnapshot.data();

    if (!updatedRole) {
      throw new HttpsError(
        "internal",
        "Role was updated but could not be read.",
      );
    }

    logger.info(
      "Role updated successfully.",
      {
        roleId,
        workshopId,
        updatedBy: callerUid,
      },
    );

    return {
      id: roleId,
      ...updatedRole,
    };
  },
);

export const deleteRole = onCall(
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

    const data = request.data as DeleteRoleData;

    const roleId =
      typeof data.roleId === "string"
        ? data.roleId.trim()
        : "";

    const workshopId =
      typeof data.workshopId === "string"
        ? data.workshopId.trim()
        : "";

    if (!roleId) {
      throw new HttpsError(
        "invalid-argument",
        "Role ID is required.",
      );
    }

    if (!workshopId) {
      throw new HttpsError(
        "invalid-argument",
        "Workshop ID is required.",
      );
    }

    const callerUid = request.auth.uid;

    await requireWorkshopPermission(
      callerUid,
      workshopId,
      "rolesDelete",
    );

    const role = await getRoleForWorkshop(
      roleId,
      workshopId,
    );

    if (role.data.isSystemRole === true) {
      throw new HttpsError(
        "permission-denied",
        "System roles cannot be deleted.",
      );
    }

    await db
      .collection("roles")
      .doc(roleId)
      .delete();

    logger.info(
      "Role deleted successfully.",
      {
        roleId,
        workshopId,
        deletedBy: callerUid,
      },
    );

    return {
      success: true,
      roleId,
      workshopId,
    };
  },
);
