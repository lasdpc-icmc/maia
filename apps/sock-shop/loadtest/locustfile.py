from locust import HttpUser, between, task
import random as r, string

def randomword(length):
   letters = string.ascii_lowercase
   return ''.join(r.choice(letters) for i in range(length))

class WebsiteUser(HttpUser):
    wait_time = between(1, 3)

    def on_start(self):
        body = {
            "username": randomword(10),
            "password": randomword(20),
            "email": randomword(5) + "@" + randomword(5) + ".com",
            "firstName": randomword(5),
            "lastName": randomword(5)
        }
        self.client.post("/register", json=body)

    @task
    def index(self):
        self.client.get("/orders")
