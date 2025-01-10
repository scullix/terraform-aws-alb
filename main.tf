resource "aws_key_pair" "key_auth" {
  key_name   = var.tag_name
  public_key = file("./.ssh/id_rsa.pub")
}

locals {
  web_servers = {
    instance1 = {
      machine_type = "t4g.nano"
      subnet_id    = aws_subnet.private_subnet_a.id
    }
    instance2 = {
      machine_type = "t4g.nano"
      subnet_id    = aws_subnet.private_subnet_b.id
    }
  }
}

resource "aws_instance" "my_app_eg1" {
  for_each = local.web_servers

  ami           = data.aws_ami.server_ami_arm.id
  instance_type = each.value.machine_type
  key_name      = aws_key_pair.key_auth.id
  subnet_id     = each.value.subnet_id
  user_data     = file("./templates/http_server_install.tpl")

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = each.key
  }

  provisioner "local-exec" {
    command = templatefile("./templates/${var.host_os}-ssh-config.tpl", {
      name         = self.tags.Name
      hostname     = self.private_ip
      user         = "ec2-user"
      identityfile = "~/.ssh/pir-aws"
    })
    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }
}
