module "im-workspace" {
 source = "terraform-google-modules/bootstrap/google//modules/im_cloudbuild_workspace"
 version = "10.0.0"

 project_id = "our-mediator-443812-i8"
 deployment_id = "gcp-scheduler-new"
 im_deployment_repo_uri = "https://github.com/mmdcloud/gcp-scheduler-pub-sub"
 im_deployment_ref = "main"

 github_app_installation_id = "43592853"
}