from locust.exception import StopUser
from random import choice, randint
from string import ascii_lowercase, digits


def randomword(length):
    return ''.join(choice(ascii_lowercase) for i in range(length))


def randomdigits(length):
    return ''.join(choice(digits) for i in range(length))


def get_random_card():
    return {
        "longNum": randomdigits(16),
        "ccv": randomdigits(3),
        "expires": f'{randint(1, 12)}/{randint(20,50)}'
    }


def get_random_address():
    return {
        "street": randomword(30),
        "number": randomdigits(4),
        "country": randomword(10),
        "city": randomword(10),
        "postcode": randomdigits(8)
    }


def create_random_user(locustUser):
    user_info = {
        "username": randomword(10),
        "password": randomword(20),
        "email": randomword(5) + "@" + randomword(5) + ".com",
        "firstName": randomword(5),
        "lastName": randomword(5)
    }

    resp = locustUser.client.post("/register", json=user_info)
    if not resp.ok:
        raise StopUser

    return user_info
