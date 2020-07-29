provider "aws" {
  version = "2.59"
  #region = "us-east-1"                                                              when we pramatirized region we dont need this line 
}

resource "aws_instance" "jenkins" {               //kapali id actik 
   
    
    ami = "${var.ami}"
    instance_type = "t2.micro"
    tags = {
      Name = "${var.Name}"
    }
  }

  variable "ami"{}
  variable "Name"{}

# data "aws_ami" "centos" {      //tuba acikti  kapattik
#   most_recent = true
#   owners      = ["679593333241"]
#   filter {
#     name   = "state"
#     values = ["available"]
#   }
#   filter {
#     name   = "name"
#     values = ["CentOS Linux 7 x86_64 HVM EBS *"]
#   }
# }

# resource "aws_key_pair" "jenkins_key" {
#   public_key = "${file("/home/tuubayalcin/.ssh/id_rsa.pub")}"
#   key_name   = "cluster"
# }

# resource "aws_instance" "jenkins" {                     //tuba acikti kapattik
#   ami           = "${data.aws_ami.centos.id}"
#   instance_type = "t2.micro"
#   # key_name      = "${aws_key_pair.jenkins_key.key_name}"
#   tags = {
#     Name = "Jenkins"
#   }
# }


  
  