import socket
import threading
from time import sleep
import json

import argparse
from utils.helpers import read_lines
from gector.gec_model import GecBERTModel


# -------------------------------------------------------------------- #
# ----------------------INITILIZE MODEL------------------------------- #

model = GecBERTModel(vocab_path='vocab/output_vocabulary',
                         model_paths='model/roberta_1_gector.th',
                         max_len=50, min_len=3,
                         iterations=5,
                         min_error_probability=0.0,
                         lowercase_tokens=0,
                         model_name='roberta',
                         special_tokens_fix=1,
                         log=False,
                         confidence=0,
                         is_ensemble=0,
                         weigths=None)

# -------------------------------------------------------------------- #


def predict_new_sentence(sentence):
	cnt_corrections = predict_for_file('data/input.txt', 'data/output.txt', model,
                                       batch_size=128)

	return cnt_corrections


def thread_func(conn):
    name = None
    global user_list
    while True:
        data = conn.recv(2 ** 14)

        if data:
            json_obj = json.loads(data.decode("utf-8"))
            print(json_obj)

            res = predict_new_sentence(json_obj['text'])
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