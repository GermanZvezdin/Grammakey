import socket
import threading
from time import sleep
import json

import re
from transformers import T5Tokenizer, T5ForConditionalGeneration

tokenizer = T5Tokenizer.from_pretrained('t5-base')
model = T5ForConditionalGeneration.from_pretrained('Model',
                                                return_dict=True)

def generate(text):
    texts = text.split(".")
    result = ""
    for txt in texts:
        model.eval()
        input_ids = tokenizer.encode("WebNLG:{} </s>".format(txt),
                                   return_tensors="pt")
        outputs = model.generate(input_ids)
        result += tokenizer.decode(outputs[0])
    result = re.sub('<pad>|</s>',"",result)
    return result

user_list = {}

def thread_func(conn):
    name = None
    global user_list
    while True:
        data = conn.recv(2 ** 14)

        if data:
            json_obj = json.loads(data.decode("utf-8"))
            print(json_obj)

            res = generate(json_obj['text'])
            for char in '\"':
                res = res.replace(char, '')
            
            conn.send(f"{res}".encode())
        else:
            print("timeout")
            break

    conn.close()
    del user_list[name]
    sleep(0.1)

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

sock.bind(('127.0.0.1', 8000))
sock.listen(10)

while True:
    conn, adr = sock.accept()
    if conn in user_list:
        continue
    x = threading.Thread(target=thread_func, args=(conn,))
    x.start()
