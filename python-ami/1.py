from asterisk.ami import SimpleAction

action = SimpleAction(
    'Originate',
    Channel='SIP/2010',
    Exten='2010',
    Priority=1,
    Context='default',
    CallerID='python',
)
client.send_action(action)
