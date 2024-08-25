import threading
import socket
import time
#Defining a function that returns internal IP. Should work fine on Mac as well
def get_internal_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # doesn't even have to be reachable
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP
alias = input('Choose an alias >>> ')
clients = []
ips = []
message_history = []
#client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#client.connect(('172.20.10.14', 59000))
maxpeers = int(input('How many peers can you support')) + 1#adding one to account for this peer itself
peers = 1 #just this one
vote = input("Would you prefer going high or low? (H/L): ")
votes = []
votes.append(vote)#start with our own vote in the list
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
port = 59000
# myhostname = socket.gethostname()
ip = get_internal_ip() #called the get_internal_ip function that'll store the ip address string in the ip variable
server.bind((ip, port))
server.listen(5) #listen with a specific backlog?? said to add a number but didnt say what number
aliases = []
aliases.append(alias)
ips.append(ip)
new = True

peer_list = []#a list of how many peers each node is willing to take
peer_list.append(maxpeers)#start with the number we ourselves are willing to accept



def negotiate():
    global maxpeers
    if peer_list:  # Check if peer_list is not empty
        if votes.count('H') > votes.count('L'):
            maxpeers = max(max(peer_list), maxpeers)
            action()
        else:
            maxpeers = min(min(peer_list), maxpeers)
            action()
    else:
        print("No peers available for negotiation.")

def action():
    global maxpeers
    message = f"{alias}: My new number of maximum peers supported on the basis of consensus is: {maxpeers}"
    print(message) #print this message for the client itself
    broadcast(message.encode('utf-8')) #this will print the same message for all the other clients


def broadcast(message):
    message_history.append(message.decode('utf-8'))
    if len(message_history)>100:
        message_history.pop(0)
    for client in clients:
        try:
            client.send(message)
        except:
            client.close()
            if client in clients:
                clients.remove(client)

def client_receive(clientnum):
    global new , maxpeers
    client = clients[clientnum]
    while client in clients:#so long as the given client is in the list
        try:
            message = client.recv(1024).decode('utf-8')
            if message == "alias?":
                client.send(alias.encode('utf-8'))
                aliases.append(client.recv(1024).decode('utf-8'))
            elif message == "new?":
                if new:
                    client.send("yes".encode('utf-8'))
                    new = False
                else:
                    client.send("no".encode('utf-8'))
                isnew = client.recv(1024).decode('utf-8')
                if isnew == "yes":
                    broadcast(f'{alias[clientnum]} has connected to the chat room'.encode('utf-8'))
            elif message == "peers?":
                client.send((str(maxpeers)).encode('utf-8'))
                peernew = client.recv(1024).decode('utf-8')
                try:
                    maxpeers = min(int(peernew), int(maxpeers))
                except ValueError:
                    print(f"Received invalid value for peers: {peernew}")
            elif message == "connected?":
                message = "" #dump the message cause there needed to be something in here
            elif message == "kill":#kill this connection since we have it already
                clients.remove(client)
                client.close()
                break
            elif message == "maxpeers?":
                client.send(str(maxpeers).encode('utf-8'))
                try:
                    peernew = int(client.recv(1024).decode('utf-8'))
                    peer_list.append(peernew)
                except ValueError:
                    print(f"Received invalid value for maxpeers: {peernew}")
            elif message in ['H','L']:
                client.send(vote.encode('utf-8'))
                votes.append(client.recv(1024).decode('utf-8'))
            elif message == "neg":
                negotiate()
            else:
                if "connected?" not in message:#just make sure the message isn't connected? so those won't print ever
                    print(message)
        except:
            print('Error!')
            client.close()
            if client in clients:
                clients.remove(client)
            break


def client_discover():
    global peers, ips, clients
    BASEIP = ""
    last = ip.rfind('.')
    for i in range (0, last + 1, 1):
        BASEIP += ip[i]
    while (peers <= maxpeers):              #while can still support more peers
        for i in range (0, 256, 1):
            newip = BASEIP + str(i)
            if newip not in ips:#this might work better
                clientnew = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                clientnew.settimeout(1)
                try:
                    if not clientnew.connect_ex((newip, 59000)):
                        clients.append(clientnew)
                        ips.append(newip)
                        thread = threading.Thread(target=client_receive, args=(clients.index(clientnew),))
                        thread.start()
                        peers += 1
                except TimeoutError:
                    print(f"Timeout connecting to {newip}")
                    clientnew.close()

def server_receive():
    global new, maxpeers, clients, aliases, ips 
    while True:
        client, address = server.accept()
        #print(f'connection is established with {str(address[0])}')
        ips.append(str(address[0]))
        client.send('alias?'.encode('utf-8'))
        aliasnew = "connected?"
        while aliasnew == "connected?":
            aliasnew = client.recv(1024).decode('utf-8')
        client.send(alias.encode('utf-8'))
        aliases.append(aliasnew)
        #client.send('new?'.encode('utf-8'))
        # isnew = client.recv(1024).decode('utf-8')
        # if new:
        #     client.send("yes".encode('utf-8'))
        #     new = False
        # else:
        #     client.send("no".encode('utf-8'))

        # if isnew == "yes":
        #     broadcast(f'{aliasnew} has connected to the chat room'.encode('utf-8'))
        client.send('maxpeers?'.encode('utf-8'))
        peernew = "connected?"
        while peernew == "connected?":
            peernew = client.recv(1024).decode('utf-8')
        peer_list.append(int(peernew))
        client.send((str(maxpeers)).encode('utf-8'))
        client.send(vote.encode('utf-8'))
        newvote = "connected?"
        while newvote == "connected?":
            newvote = client.recv(1024).decode('utf-8')
        votes.append(newvote)
        for msg in message_history:
                client.send(f'History: {msg}'.encode('utf-8'))
                #short sleep so messages don't jumble
                time.sleep(0.1)
        clients.append(client)
        thread = threading.Thread(target=client_receive, args=(clients.index(client),))
        thread.start()


def client_send():
    global alias
    while True:
        message = input("")
        if message == "neg":
            negotiate()
        message = f'{alias}: {message}'
        broadcast(message.encode('utf-8'))

def maintain_line():
    while True:
        time.sleep(0.1)#sleep for one second then broadcast connected?
        broadcast("connected?".encode('utf-8'))

discover_thread = threading.Thread(target=client_discover)
discover_thread.start()



receive_thread = threading.Thread(target=server_receive)
receive_thread.start()

send_thread = threading.Thread(target=client_send)
send_thread.start()

maintain_thread = threading.Thread(target=maintain_line)
maintain_thread.start()
