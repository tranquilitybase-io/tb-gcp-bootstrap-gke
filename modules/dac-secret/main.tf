resource "random_password" "password" {
  length = 10
  special = true
  override_special = "_%@"
}

## Creates Dac username and password in the cicd namespace ##

resource "null_resource" "kubernetes_dac_secret_cicd" {
  triggers = {
    content = var.content
    k8_name = var.context_name
  }

  provisioner "local-exec" {
    command = "echo 'kubectl --context=${var.context_name} create secret generic dac-user-pass -n cicd --from-literal=username=dac --from-literal=password='${random_password.password.result}' --type=kubernetes.io/basic-auth' | tee -a ./kube.sh"
  }

  provisioner "local-exec" {
    command = "echo 'kubectl --context=${self.triggers.k8_name} delete secret dac-user-pass' -n cicd | tee -a ./kube.sh"
    when    = destroy
  }
}

## Creates Dac username and password in the ssp namespace ##

resource "null_resource" "kubernetes_dac_secret_ssp" {
  triggers = {
    content = var.content
    k8_name = var.context_name
  }

  provisioner "local-exec" {
    command = "echo 'kubectl --context=${var.context_name} create secret generic dac-user-pass -n ssp --from-literal=username=dac --from-literal=password='${random_password.password.result}' --type=kubernetes.io/basic-auth' | tee -a ./kube.sh"
  }

  provisioner "local-exec" {
    command = "echo 'kubectl --context=${self.triggers.k8_name} delete secret dac-user-pass' -n ssp | tee -a ./kube.sh"
    when    = destroy
  }
}