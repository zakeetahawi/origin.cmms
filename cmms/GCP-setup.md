# GCP Setup tutorial
1. Create a Google cloud storage bucket. Use default values.
2. At this step: Choose how to control access to objects: choose fine-grained as access control
3. After creation, Click on the left menu and navigate to **IAM & Admin** -> **Service Accounts**.
4. Click on **CREATE SERVICE ACCOUNT**.
5. Fill in the required details.
6. At the second step (**Grant this service account access to project**), select a role. Scroll down until you see **Cloud Storage** and select the role **Storage Admin**.
7. Click on the created service account email.
8. Click on **KEYS** -> **ADD KEY** -> **Create new key**.
9. When prompted for the key type, choose **JSON**. The key will then be downloaded.
