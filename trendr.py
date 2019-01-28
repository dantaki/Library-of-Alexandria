#!/usr/bin/env python
import tweepy
import tkinter
import datetime,json,os,random,sys,textwrap,time
import twit
def get_trends(woeids,api):
	trends = []
	for wid in woeids:
		trd = api.trends_place(wid)
		for i in range(0,len(trd)):
			for j in range(0,len(trd[i]['trends'])):
				trends.append(trd[i]['trends'][j]['name'])
	return trends
def output_trends(trends):
	ts = datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d')
	out = "trends/{}.trends.txt".format(ts)
	ofh = open(out,'w')
	for x in trends: ofh.write('{}\n'.format(x))
	ofh.close()
	return out
def twitter(scroll):
	done = [] 	
	ln = [ '-' for x in range(0,80) ]
	ln = ''.join(ln)
	log = scroll.replace("txt","log")
	with open(log,'r') as f:
		for l in f:
			done.append(l.rstrip())
	lib,trd = {},{}
	with open(scroll,'r') as f:
		for l in f: 
			ind,trend, tweet = l.rstrip().split('\t')
			if ind in done: continue 
			if trd.get(trend)==None: trd[trend]=[ind]
			else: trd[trend].append(ind)
			if lib.get(ind)==None: lib[ind]=[tweet]
			else: lib[ind].append(tweet)
	trds = sorted(list(set(list(trd.keys()))))
	trds = ' * '.join(trds)
	sys.stdout.write('TRENDS:\n{}\n{}\n{}\n'.format(ln,textwrap.fill(trds,80),ln))
	chosen = input("Pick a trend... ")
	nums = None
	if trd.get(chosen)==None:
		sys.stderr.write('ERROR: {} NOT IN TRENDS... Exiting\n'.format(chosen))
		sys.exit(1)
	else: 
		nums = trd[chosen]
	sys.stdout.write('\n>>> {}: Unique Tweets:{} <<<\n\n'.format(chosen,len(nums)))
	lfh = open(log,'a')
	random.shuffle(nums)
	sys.stderr.write('tweeting...\n')
	num = nums[0]
	lfh.write('{}\n'.format(num))
	lfh.close()
	sys.stderr.write('{}\n{} chosen by the gods\n{}\n\n\n'.format(ln,num,ln))
	last_status=None
	for tweet in lib[num]: 
		sys.stderr.write('{}\n{}\n{}\n\n'.format(ln,textwrap.fill(tweet,80),ln))
		if last_status == None:
			last_status = api.update_status(status=tweet)
		else:
			last_status = api.update_status(status=tweet,in_reply_to_status_id=last_status.id)
if __name__ == "__main__":
	api = twit.access_twitter('tweet.json')
	woeid = [
	23424977, #US
	23424975, #UK
	23424775, #CAN
	23424748, #AUS
	23424916, #NZ
	23424803, #IRE
	23424853, #ITL
	23424829, #GER
	23424819, #FRA
	23424848, #IND
	23424957, #SWZ
	23424950, #SPA
	23424856, #JPN
	]
	trends = get_trends(woeid,api)
	trd_out = output_trends(trends)
	t = os.system("perl parse_trends.pl {}".format(trd_out))
	twit.create_log(trd_out.replace(".txt",".tweets.log"))
	twitter(trd_out.replace(".txt",".tweets.txt"))
	tweet_again = input("Tweet again? [y/n]\n")
	while tweet_again=='y':
		twitter(trd_out.replace(".txt",".tweets.txt"))
		tweet_again = input("Tweet again? [y/n]\n")