sudo apt-get update
sudo apt-get install curl -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update -y
apt-cache policy docker-ce
sudo apt-get install -y docker-ce -y
