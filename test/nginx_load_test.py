#!/usr/bin/env python3

import concurrent.futures
import requests
import time

out = []
CONNECTIONS = 100
TIMEOUT = 5
REQUESTS_PER_URL = 20000

urls = [ 'http://localhost:8080', 'http://localhost:8081'] * REQUESTS_PER_URL

print(len(urls))

def load_url(url, timeout):
    ans = requests.head(url, timeout=timeout)
    return ans.status_code

with concurrent.futures.ThreadPoolExecutor(max_workers=CONNECTIONS) as executor:
    future_to_url = (executor.submit(load_url, url, TIMEOUT) for url in urls)
    time1 = time.time()
    for future in concurrent.futures.as_completed(future_to_url):
        try:
            data = future.result()
        except Exception as exc:
            data = str(type(exc))
        finally:
            out.append(data)

            print(str(len(out)),end="\r")

    time2 = time.time()

print(f'Took {time2-time1:.2f} s')
