from locust import HttpUser, between, task
from locust.exception import StopUser
from base64 import b64encode
from random import choice, randint
from string import ascii_lowercase, digits


def randomword(length):
    return ''.join(choice(ascii_lowercase) for i in range(length))


def randomdigits(length):
    return ''.join(choice(digits) for i in range(length))


def gen_base64_login(username, password):
    login_data = bytes(username + ':' + password, encoding='ascii')
    return f"Basic {b64encode(login_data).decode('ascii')}"


class UserStresser(HttpUser):
    wait_time = between(0.1, 0.3)

    def __init__(self, *args, **kwargs):
        self.user_info = {}
        super().__init__(*args, **kwargs)

    def create_random_user(self):
        self.user_info = {
            "username": randomword(10),
            "password": randomword(20),
            "email": randomword(5) + "@" + randomword(5) + ".com",
            "firstName": randomword(5),
            "lastName": randomword(5)
        }

        with self.client.post("/register",
                              json=self.user_info,
                              catch_response=True) as resp:

            if not resp.ok:
                resp.failure("Failed user registration")
                raise StopUser

    def on_start(self):
        self.create_random_user()

    @task(1)
    def create_new_user(self):
        self.create_random_user()

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

        with self.client.get("/login",
                             headers={"Authorization": b64login},
                             catch_response=True) as resp:
            if not resp.ok:
                resp.failure("Could not log in again")
                raise StopUser

    @task(10)
    def post_card(self):
        new_card = {
            "longNum": randomdigits(16),
            "ccv": randomdigits(3),
            "expires": f'{randint(1, 12)}/{randint(2020,2050)}'
        }

        with self.client.post("/cards", json=new_card,
                              catch_response=True) as resp:
            if not resp.ok:
                resp.failure("Failed adding card")
                return
            resp_json = resp.json()
            card_id = resp_json["id"]

        with self.client.get(f"/cards/{card_id}",
                             catch_response=True,
                             name="/cards/<card_id>") as resp:
            
            if (not resp.ok) or ("error" in resp.json().keys()):
                resp.failure("Failed getting new card")
                return
            resp_json = resp.json()

            for key in new_card.keys():
                if key not in resp_json.keys() or  \
                   new_card[key] != resp_json[key]:
                    resp.failure("Card data does not match")

    @task(5)
    def post_address(self):
        new_address = {
            "street": randomword(30),
            "number": randomdigits(4),
            "country": randomword(10),
            "city": randomword(10),
            "postcode": randomdigits(8)
        }

        with self.client.post("/addresses",
                              json=new_address,
                              catch_response=True) as resp:
            
            if (not resp.ok) or ("error" in resp.json().keys()):
                resp.failure("Failed adding address")
                return

        # as the path /addresses/<address_id> is not implemented, 
        # there is no way to check if the data is correct for a given request,
        # only the first address can be accessed at /address

    @task(5)
    def get_full_db(self):
        for path in ["customers", "cards", "addresses"]:
            with self.client.get(f"/{path}", catch_response=True) as resp:
                if not resp.ok:
                    resp.failure(f"Failed getting {path}")
