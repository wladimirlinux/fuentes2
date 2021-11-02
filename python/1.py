import os

 

hostname = "8.8.8.8"

# response = os.system("ping -c 1 " + hostname) -> este seria para Windows

response = os.system("ping -c 1 " + hostname + " > /dev/null 2>&1")

 

 

if response == 0:

    print ("%s responde" % hostname)

else:

    print ("%s no responde" % hostname)
