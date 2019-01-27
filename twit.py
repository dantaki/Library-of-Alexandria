#!/usr/bin/env python
import tweepy
import tkinter
import json,os,random,sys,textwrap,time
#########################
# LIBRARY OF ALEXANDRIA #
#########################
def access_twitter(conf):
	with open(conf,'r') as f: data = json.load(f)
	auth = tweepy.OAuthHandler(data['consumer_key'], data['consumer_secret'])
	auth.set_access_token(data['access_token'], data['access_token_secret'])
	api = tweepy.API(auth,wait_on_rate_limit_notify=True)
	return api
def create_log(log):
	if not os.path.isfile(log): 
		lfh = open(log,'w')
		lfh.close()
def twitter(scroll):
	done = [] 
	log = scroll.replace("txt","log")
	with open(log,'r') as f:
		for l in f:
			done.append(l.rstrip)
	lib = {}
	with open(scroll,'r') as f:
		for l in f: 
			ind, tweet = l.rstrip().split('\t')
			if ind in done: continue 
			if lib.get(ind)==None: lib[ind]=[tweet]
			else: lib[ind].append(tweet)
	lfh = open(log,'a')
	ind = list(lib.keys())
	random.shuffle(ind)
	sys.stderr.write('tweeting...\n')
	num = ind[0]
	lfh.write('{}\n'.format(num))
	lfh.close()
	ln = [ '-' for x in range(0,80) ]
	ln = ''.join(ln)
	sys.stderr.write('{}\n{} chosen by the gods\n{}\n\n\n'.format(ln,num,ln))
	last_status=None
	for tweet in lib[num]: 
		sys.stderr.write('{}\n{}\n{}\n\n'.format(ln,textwrap.fill(tweet,80),ln))
		if last_status == None:
			last_status = api.update_status(status=tweet)
		else:
			last_status = api.update_status(status=tweet,in_reply_to_status_id=last_status.id)

if __name__ == "__main__":
	scroll = sys.argv[1]
	create_log(scroll.replace("txt","log"))
	api = access_twitter('tweet.json')
	if len(sys.argv) > 1:
		iters = sys.argv[2]
		for i in range(0,int(iters)):
			twitter(scroll)
			time.sleep(12)
	else: twitter(scroll) 
