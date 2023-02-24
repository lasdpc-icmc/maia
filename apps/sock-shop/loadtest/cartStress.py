from locust import HttpUser, between, task
from locust.exception import StopUser
from random import randint, choice

from common import create_random_user


class CartStresser(HttpUser):
    wait_time = between(0.1, 0.2)

    def __init__(self, *args, **kwargs):
        self.logged_in = False
        self.cart = {}
        self.item_list = []
        super().__init__(*args, **kwargs)

    def on_start(self):
        if randint(0, 1):
            #sometimes login instead of using session for not skewing data
            create_random_user(self)
            self.logged_in = True
        
        catalogue = self.client.get("/catalogue")
        if not catalogue.ok:
            raise StopUser
        
        for item in catalogue.json():
            self.item_list.append(item["id"])

    @task(1)
    def merge_carts(self):
        if self.logged_in:
            return
        
        create_random_user(self)
        self.logged_in = True

    @task(1)
    def clear_cookies(self):
        self.client.cookies.clear()
        self.logged_in = False
        self.cart = {}

    @task(100)
    def get_cart(self):
        with self.client.get("/cart", catch_response=True) as cart:
            if not cart.ok:
                return
            if not self.check_items(cart.json()):
                cart.failure("Cart data does not match")

    def check_items(self, cart):
        if len(cart) != len(self.cart):
            return False

        try:
            for item in cart:
                if item["quantity"] != self.cart[item["itemId"]]:
                    return False

            return True
        except KeyError:
            return False

    @task(100)
    def post_item(self):
        id = choice(self.item_list)
        resp = self.client.post("/cart", json={"id":id})
        if not resp.ok:
            return

        if id not in self.cart.keys():
            self.cart[id] = 1
            return
        
        self.cart[id] += 1

    @task(10)
    def delete_item(self):
        if len(self.cart.keys()) == 0:
            return
        
        id = choice(list(self.cart.keys()))
        resp = self.client.delete(f"/cart/{id}", name="/cart/<id>")
        if not resp.ok:
            return

        self.cart.pop(id)

    @task(50)
    def update_item(self):
        if len(self.cart.keys()) == 0:
            return

        id = choice(list(self.cart.keys()))
        amount = randint(0, 10)

        resp = self.client.post(f"/cart/update", 
            json={"id":id, "quantity":amount}
        )
        if not resp.ok:
            return

        self.cart[id] = amount
