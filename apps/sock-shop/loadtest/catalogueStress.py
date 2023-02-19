from locust import HttpUser, between, task
from random import randint, sample

from common import create_random_user


class CatalogueStresser(HttpUser):
    wait_time = between(0.1, 0.3)

    def on_start(self):
        if randint(0, 1):
            #sometimes login instead of using session for not skewing data
            create_random_user(self)

    @task
    def get_catalogue(self):

        tags = self.client.get("/tags")
        if not tags.ok:
            return
        tags = tags.json()["tags"]

        size = self.client.get("/catalogue/size")
        if not size.ok:
            return
        size = size.json()["size"]

        page = 1
        while True:
            tag_amount = randint(0, len(tags))

            path = "/catalogue?"
            if tag_amount != 0:
                path += f"tags={','.join(sample(tags, tag_amount))}&"

            path += f"size={randint(1, size)}&page={page}"


            catalogue = self.client.get(path, name="/catalogue")
            if (not catalogue.ok) or (catalogue.text in ["null", "[]\n"]):
                break
        
            self.get_images(catalogue.json())
            page += 1

    def get_images(self, catalogue):
        for item in catalogue:
            for imageUrl in item["imageUrl"]:
                self.client.get(imageUrl, name="/catalogue/<image>")