import socket
import threading
from time import sleep
import json

from transformers import AutoModelWithLMHead, AutoTokenizer, AutoConfig
import torch

tokenizer = AutoTokenizer.from_pretrained('microsoft/DialoGPT-medium')
conf = AutoConfig.from_pretrained('./output-medium')
model = AutoModelWithLMHead.from_pretrained('output-medium', config=conf)

def bot_response(text):
	user_input = tokenizer.encode(text + tokenizer.eos_token, return_tensors='pt')
	response = model.generate(
        user_input, max_length=200,
        pad_token_id=tokenizer.eos_token_id,  
        no_repeat_ngram_size=3,       
        do_sample=True, 
        top_k=100, 
        top_p=0.7,
        temperature = 0.8
        )

	result = f"{tokenizer.decode(response[0], skip_special_tokens=True)}"
	return result


user_list = {}

def thread_func(conn):
    name = None
    global user_list
    while True:
        data = conn.recv(2 **  14)
        if data:
            json_obj = json.loads(data.decode("utf-8"))
            print(json_obj)

            res = bot_response(json_obj['text'])

            print(f'\n res = \n',res)
	    
            conn.send(f"{res}".encode())
        else:
            print("timeout")
            break

    conn.close()
    del user_list[name]



if __name__ == '__main__':

	sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	sock.bind(('127.0.0.1', 8010))
	sock.listen(10)

	while True:
	    conn, adr = sock.accept()
	    if conn in user_list:
	        continue
	    x = threading.Thread(target=thread_func, args=(conn,))
	    x.start()


