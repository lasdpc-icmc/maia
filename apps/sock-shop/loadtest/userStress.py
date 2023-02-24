from locust import HttpUser, between, task
from locust.exception import StopUser
from base64 import b64encode
from random import randint

from common import create_random_user, get_random_card, get_random_address


def gen_base64_login(username, password):
    login_data = bytes(username + ':' + password, encoding='ascii')
    return f"Basic {b64encode(login_data).decode('ascii')}"


class UserStresser(HttpUser):
    wait_time = between(0.1, 0.3)

    def __init__(self, *args, **kwargs):
        self.user_info = {}
        super().__init__(*args, **kwargs)

    def on_start(self):
        self.user_info = create_random_user(self)

    @task(1)
    def create_new_user(self):
        self.user_info = create_random_user(self)

    @task(10)
    def fail_register(self):
        with self.client.post("/register",
                              json=self.user_info,
                              catch_response=True) as resp:

            if resp.ok:
                resp.failure("User registration of already existing user")
                return
            resp.success()

    @task(20)
    def relogin(self):
        self.client.cookies.clear()

        b64login = gen_base64_login(self.user_info["username"],
                                    self.user_info["password"])

        resp = self.client.get("/login", headers={"Authorization": b64login})
        if not resp.ok:
            raise StopUser

    @task(10)
    def post_card(self):
        new_card = get_random_card()

        resp = self.client.post("/cards", json=new_card)
        if not resp.ok:
            return
        
        card_id = resp.json()["id"]

        with self.client.get(f"/cards/{card_id}",
                             catch_response=True,
                             name="/cards/<card_id>") as resp:

            if not resp.ok:
                return
            resp_json = resp.json()

            for key in new_card.keys():
                if key not in resp_json.keys() or  \
                   new_card[key] != resp_json[key]:
                    resp.failure("Card data does not match")

    @task(5)
    def post_address(self):
        new_address = get_random_address()

        self.client.post("/addresses", json=new_address)

        # as the path /addresses/<address_id> is not implemented,
        # there is no way to check if the data is correct for a given request,
        # only the first address can be accessed at /address

    @task(5)
    def get_full_db(self):
        for path in ["customers", "cards", "addresses"]:
            self.client.get(f"/{path}")
