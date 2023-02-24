from locust import HttpUser, constant, task
from random import choice


paths = [
    "/login", "/cart", "/customers", "/cards", "/address", "/card",
    "/catalogue", "/catalogue/size", "/catalogue/tags"
]

class SessionStresser(HttpUser):
    wait_time = constant(0)

    @task
    def clear_cookie(self):
        self.client.cookies.clear()
        
    @task
    def get_random_page(self):
        with self.client.get(choice(paths), catch_response=True) as resp:
            if self.client.cookies.get("md.sid") is None:
                resp.failure("Session cookie not set")
            resp.success()
