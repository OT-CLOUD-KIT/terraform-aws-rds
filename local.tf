locals {
  base_name = "${var.env}-${var.app}"

  common_tags = {
    env = var.env
    owner =  var.owner
    app = var.app
  }
}
