provider "aws" {
  region = "us-east-1"
}
########## Key-Pair generation ##########

resource "aws_key_pair" "deployer" {
  key_name   = "instancekey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLHkKMC3ahCNP+b8I6L2r/NU7ktxZEbUqQkHPAcAkGqAwm4uODUAEN8kTbkBrwKHjATYMudGD2NJR+HzambCVBWR4ZLxB+YNAIJcBS3HfszuscvS5Gal14qJQjM0kEKr+ZQ8+39HEeTshRQ9DuY8T5k6xLXPhBFJJpLAvlfNhp9sy5R290bn3rAvN/Ygy55H4TDwTAENA43l6vDe+QXlYYVMYlaURcHvQ2KOL/4u6hDGISlch+1Oc3Ai35Hu/jnOWngMOd01gEFq9/ar/MaN5NLNnbB+tYCacOWLKQ64S2XMh7S4sRansfNRdwMm3T9Lq1Kxk/XtiHWPDSlGrMpjEZ administrator@DESKTOP-RPOKH2V"
}

######## data-block fetching ami-id ########
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  owners = ["amazon"] # Canonical
}




########### Instance ###########
resource "aws_instance" "provisionerinstance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "instancekey"
  vpc_security_group_ids = [aws_security_group.main.id]

  provisioner "file" {
    source      = "./transfer.sh"
    destination = "/home/ubuntu/transfer.sh"
  }
 
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("./instancekey")
    timeout     = "4m"
  }

  tags = {
    Name = "test-instance"
  }




}


resource "aws_security_group" "main" {
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    }
  ]
}



