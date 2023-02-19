from locust import HttpUser, between, task
from locust.exception import StopUser
from random import choice

from common import create_random_user, get_random_card, get_random_address


class OrderStresser(HttpUser):
    wait_time = between(0.1, 0.2)

    def __init__(self, *args, **kwargs):
        self.item_prices = {}
        self.no_orders = 0
        self.total_price = 4.99 #shipping price
        super().__init__(*args, **kwargs)

    def on_start(self):
        create_random_user(self)

        catalogue = self.client.get("/catalogue")
        if not catalogue.ok:
            raise StopUser
        
        for item in catalogue.json():
            self.item_prices[item["id"]] = item["price"]


        card_data = get_random_card()
        address_data = get_random_address()

        if not self.client.post("/cards", json=card_data).ok:
            raise StopUser
        
        if not self.client.post("/addresses", json=address_data).ok:
            raise StopUser

    @task(1)
    def add_item_to_cart(self):
        id = choice(list(self.item_prices.keys()))
        resp = self.client.post("/cart", json={"id":id})
        if not resp.ok:
            return

        self.total_price += self.item_prices[id]

    @task(3)
    def post_order(self):
        with self.client.post("/orders", catch_response=True) as resp:
            if self.total_price > 100:
                if resp.status_code == 406:
                    resp.success()
                    return
                elif resp.ok:
                    resp.failure("Payment should not have been accepted")
                    return
        
        self.no_orders += 1
            
    @task(3)
    def get_orders(self):
        with self.client.get("/orders", catch_response=True) as orders:
            if not orders.ok:
                return
            if len(orders.json()) != self.no_orders:
                print(orders.json())
                orders.failure("Number of orders does not match")
