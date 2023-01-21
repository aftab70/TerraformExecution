sudo apt-get update
sudo apt-get install curl -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update -y
apt-cache policy docker-ce
sudo apt-get install -y docker-ce -y

sudo tee adsterra.py<<EOF
import time
import pytest
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager


options = Options()
options.add_argument('--headless')
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)



driver.get('https://gaming-maniya.blogspot.com/')
print(driver.title)
time.sleep(5)
driver.find_element(By.XPATH, '//*[@id="PopularPosts2"]/div/div/div[1]/a/div/h2').click()
time.sleep(5)
print(driver.title)


driver.get('https://gaming-maniya.blogspot.com/')
print(driver.title)
time.sleep(5)
driver.find_element(By.XPATH, '//*[@id="PopularPosts2"]/div/div/div[2]/div[1]/div/h2/a').click()
print(driver.title)
time.sleep(5)


driver.get('https://gaming-maniya.blogspot.com/')
print(driver.title)
time.sleep(5)
driver.find_element(By.XPATH, '//*[@id="PopularPosts2"]/div/div/div[2]/div[2]/div/h2/a').click()
print(driver.title)
time.sleep(5)


driver.get('https://kali-llinux.blogspot.com/')
print(driver.title)
time.sleep(5)
driver.find_element(By.XPATH, '//*[@id="Blog1"]/div[1]/div[2]/article[1]/div/h2/a').click()
time.sleep(5)
print(driver.title)


driver.get('https://kali-llinux.blogspot.com/')
print(driver.title)
time.sleep(5)
driver.find_element(By.XPATH, '//*[@id="Blog1"]/div[1]/div[2]/article[2]/div/h2/a').click()
time.sleep(5)
print(driver.title)
EOF



sudo tee Dockerfile<<EOF
FROM python:3.8
# Adding trusting keys to apt for repositories
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
# Adding Google Chrome to the repositories
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
# Updating apt to see and install Google Chrome
RUN apt-get -y update
# Magic happens
RUN apt-get install -y google-chrome-stable
# Installing Unzip
RUN apt-get install unzip -y
# Download the Chrome Driver
RUN wget https://chromedriver.storage.googleapis.com/94.0.4606.61/chromedriver_linux64.zip 
RUN unzip chromedriver_linux64.zip 
# Unzip the Chrome Driver into /usr/local/bin directory
RUN mv chromedriver /usr/bin/chromedriver 
RUN chown root:root /usr/bin/chromedriver 
RUN chmod +x /usr/bin/chromedriver 
# Installing selenium 
RUN python3 -m pip install pytest
RUN python3 -m pip install selenium
RUN python3 -m pip install webdriver_manager
# Set display port as an environment variable
ENV DISPLAY=:99
RUN mkdir /app
COPY adsterra.py /app
WORKDIR /app
#RUN pip install --upgrade pip
#RUN pip install -r requirements.txt
CMD ["python3", "./adsterra.py"]
EOF

sudo docker build . -t adsterra:latest
sudo docker run adsterra:latest
