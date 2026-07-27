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