import sys

for eachArg in sys.argv:
    print("Python got " + eachArg)
res = `python ~/live/test.py '{"username":#{params[:user][:account_attributes][:username]}, "invite_end": #{params[:user][:invite_code]}}'`

