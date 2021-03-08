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
                     model_paths=['model/roberta_1_gector.th',],
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

def predict_for_file(input_file, output_file, model, batch_size=32):
    test_data = read_lines(input_file)
    predictions = []
    cnt_corrections = 0
    batch = []
    for sent in test_data:
        batch.append(sent.split())
        if len(batch) == batch_size:
            preds, cnt = model.handle_batch(batch)
            predictions.extend(preds)
            cnt_corrections += cnt
            batch = []
    if batch:
        preds, cnt = model.handle_batch(batch)
        predictions.extend(preds)
        cnt_corrections += cnt

    with open(output_file, 'w') as f:
        f.write("\n".join([" ".join(x) for x in predictions]) + '\n')
    return cnt_corrections


def predict_new_sentence(sentence):
	with open('data/input.txt', 'w') as f_in:
		f_in.write(sentence)
	cnt_corrections = predict_for_file('data/input.txt', 'data/output.txt', model,
                                       batch_size=128)
	print("CNT=", cnt_corrections)
	with open('data/output.txt', 'r') as f_out:
		file = f_out.read()

	return cnt_corrections, file.rstrip()


user_list = {}

def thread_func(conn):
    name = None
    global user_list
    while True:
        data = conn.recv(2 **  14)
        if data:
            json_obj = json.loads(data.decode("utf-8"))

            cnt, res = predict_new_sentence(json_obj['text'])
            if cnt != 0:
                err = "Sory, but you have mistake. "
                res = err + res

            print(f'\n res = \n',res)
	    
            conn.send(f"{res}".encode())
        else:
            print("timeout")
            break

    conn.close()
    del user_list[name]


if __name__ == '__main__':

	sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	sock.bind(('127.0.0.1', 8000))
	sock.listen(10)

	while True:
	    conn, adr = sock.accept()
	    if conn in user_list:
	        continue
	    x = threading.Thread(target=thread_func, args=(conn,))
	    x.start()