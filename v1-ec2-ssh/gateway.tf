resource "aws_internet_gateway" "my_app" {
  vpc_id = aws_vpc.main.id
}