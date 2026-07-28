# SecureCart Engineering Journal

---

## Session 1 - Development Environment & Kubernetes Lab

### Goal

Build the local Kubernetes development environment for SecureCart using Kind.

### Completed

- Created the SecureCart GitHub repository.
- Built the initial project structure.
- Installed Docker.
- Installed kubectl.
- Installed Kind.
- Installed Helm.
- Created the first two-node Kind cluster.
- Verified cluster connectivity using kubectl.

### Challenges

#### VMware Disk Expansion

Increasing the virtual disk size did not immediately provide additional storage inside Ubuntu.

Resolution:
- Removed VMware snapshots.
- Expanded the partition using `growpart`.
- Resized the filesystem using `resize2fs`.
- Verified the operating system recognized the additional space.

#### Kind Installation

The initial Kind installation attempt failed because the download/checksum approach was incorrect.

Resolution:
- Downloaded the official Kind binary.
- Installed it into `/usr/local/bin`.
- Verified the installation with:

```bash
kind version


### Lessons Learned

- Expanding a VMware virtual disk requires both resizing the guest partition and the filesystem.
- Installing tools from the official project documentation helps avoid outdated installation methods.
- Infrastructure configuration should be stored in source control so environments can be recreated consistently.

### Next Session

- Deploy the first Kubernetes workload.
- Learn Pods and Deployments.

## Session 2 - First Kubernetes Pod

### Goal

Deploy and inspect the first SecureCart workload on the local Kind cluster.

### Completed

- Created a Kubernetes Pod manifest for the SecureCart frontend.
- Deployed an NGINX container to the cluster.
- Verified the Pod reached the Running and Ready states.
- Inspected Pod scheduling, container status, and Kubernetes events.
- Tested the application using kubectl port forwarding.
- Deleted the standalone Pod and confirmed Kubernetes did not recreate it.

### Lessons Learned

- A Pod is Kubernetes' smallest deployable workload unit.
- Labels provide metadata that other Kubernetes resources can use to identify workloads.
- Declaring a container port does not expose the workload outside the Pod.
- Port forwarding provides temporary local access for testing.
- A standalone Pod is not automatically recreated after deletion.
- Deployments provide workload reconciliation and self-healing behavior.

### Next

- Replace the standalone Pod with a Deployment.
- Configure replicas.
- Test Kubernetes workload recovery.