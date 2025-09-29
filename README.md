# Overleaf Community Edition Helm Chart

A Helm chart to deploy [Overleaf Community Edition](https://github.com/overleaf/overleaf) on Kubernetes.

---


## Installation

Clone the repository and install using Helm:

```bash
git clone https://github.com/Nifri2/overleaf-helm.git
cd overleaf-helm
helm upgrade --install overleaf ./overleaf-helm --namespace overleaf --create-namespace
```


### Creating the First Admin User

As long as the Helm Job for creating the admin user doesn't work, you can use the following script to generate a user manually:

```bash
./create-overleaf-admin.sh --email admin@example.com --admin
```


# Configuration
The following table lists the configurable parameters of this chart and their default values.
| Parameter      | Description                               | Default |
| -------------- | ----------------------------------------- | ------- |
| `replicaCount` | Number of ShareLaTeX/Overleaf pods to run | `1`     |


## ShareLaTeX / Overleaf
| Parameter                | Description                                        | Default                      |
| ------------------------ | -------------------------------------------------- | ---------------------------- |
| `sharelatex.image`       | Docker image for Overleaf                          | `sharelatex/sharelatex`      |
| `sharelatex.appName`     | Application name displayed in UI                   | `Overleaf Community Edition` |
| `sharelatex.redisHost`   | Redis host for Overleaf                            | `redis`                      |
| `sharelatex.mongoUrl`    | MongoDB connection string                          | `mongodb://mongo/sharelatex` |
| `sharelatex.nodePort`    | Node port for the service                          | `80`                         |
| `sharelatex.storageSize` | Storage size for Overleaf data                     | `5Gi`                        |
| `sharelatex.mountPath`   | Mount path inside the container                    | `/var/lib/overleaf`          |
| `sharelatex.extraEnv`    | Additional environment variables for customization | See values below             |

### Example extraEnv values:
```yaml
- name: OVERLEAF_SITE_URL
  value: "https://overleaf.maxresdefault.zip"
- name: OVERLEAF_CONTACT_EMAIL
  value: "something@example.com"
- name: OVERLEAF_NAV_TITLE
  value: "Overleaf CE Helm Chart"
- name: OVERLEAF_LEFT_FOOTER
  value: '[{"text": "Packaged by <a href=\"https://github.com/Nifri2/overleaf-helm\">Nifri</a>"} ]'
- name: OVERLEAF_RIGHT_FOOTER
  value: '[{"text": "Another thingy"} ]'
```
> Additional environment variables can be added to sharelatex.extraEnv to configure site URL, header image, admin email, custom footer, or SMTP settings.


## Admin User Creation (Job) (WIP)
| Parameter               | Description                                    | Default                      |
| ----------------------- | ---------------------------------------------- | ---------------------------- |
| `admin.create`          | Whether to create an initial admin user        | `false`                      |
| `admin.email`           | Admin email address                            | `admin@admin.com`            |
| `admin.useSecret`       | If true, use Kubernetes Secret for credentials | `false`                      |
| `admin.secret.name`     | Name of the secret to use for credentials      | `overleaf-admin-credentials` |
| `admin.secret.emailKey` | Key in the secret for the email                | `username`                   |
| `admin.job.image`       | Image for running the admin creation job       | `alpine/kubectl:1.34.1`      |

> **Note**: The admin creation job prints an activation URL to logs that you must visit to set the password.

## MongoDB
| Parameter           | Description               | Default      |
| ------------------- | ------------------------- | ------------ |
| `mongo.image`       | MongoDB image             | `mongo:6.0`  |
| `mongo.database`    | Name of Overleaf database | `sharelatex` |
| `mongo.storageSize` | Persistent volume size    | `5Gi`        |
| `mongo.mountPath`   | Path to mount data        | `/data/db`   |

## Redis
| Parameter           | Description            | Default     |
| ------------------- | ---------------------- | ----------- |
| `redis.image`       | Redis image            | `redis:6.2` |
| `redis.storageSize` | Persistent volume size | `2Gi`       |
| `redis.mountPath`   | Path to mount data     | `/data`     |

## Persistence
| Parameter                  | Description                          | Default         |
| -------------------------- | ------------------------------------ | --------------- |
| `persistence.enabled`      | Enable persistence for Overleaf data | `true`          |
| `persistence.storageClass` | Storage class to use for PVCs        | `longhorn`      |
| `persistence.accessMode`   | PVC access mode                      | `ReadWriteOnce` |

## Ingress
| Parameter             | Description                          | Default                                            |
| --------------------- | ------------------------------------ | -------------------------------------------------- |
| `ingress.enabled`     | Enable ingress for Overleaf          | `true`                                             |
| `ingress.className`   | Ingress class                        | `contour`                                          |
| `ingress.annotations` | Annotations for the ingress resource | `cert-manager.io/cluster-issuer: letsencrypt-prod` |
| `ingress.hosts`       | Hostnames and paths for ingress      | `overleaf.maxresdefault.zip`                       |
| `ingress.tls`         | TLS configuration                    | Secret name: `sharelatex-tls`                      |
