from asterisk.ami import AMIClient

client = AMIClient(address='127.0.0.1',port=5038)
client.login(username='admin',secret='123321')
