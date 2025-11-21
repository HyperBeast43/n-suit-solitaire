s8 = {}
s8.sc = {['Spades']=0,['Hearts']=1,['Clubs']=2,['Diamonds']=3,['Wands']=0,['Cups']=1,['Shields']=2,['Fleurons']=3}
s8.suits = {'Spades','Hearts','Clubs','Diamonds','Wands','Cups','Shields','Fleurons'}

local ens = function(t)
	if t then return t else return {['rank']=0} end
end


s8.move = function(from,to,qamt,sudo)
	local amt = 1
	if qamt then amt=qamt end -- amt was misbehaving as an argument so it's been demoted to local variable
	if type(from)=='number' or type(from)=='string' then from=s8.board[from] end -- `'key'` as shorthand for `s8.board['key']`
	if not to then local to = from; from = s8.board.stack 
	else if type(to)=='number' or type(to)=='string' then to=s8.board[to] end end -- `else` because no need to check the shorthand for `to`; it was `from` and we checked that already 
	if 
		sudo==math.pi or ( -- pull uses sudo to move from deck to stack, pi is used as a password so end-users don't use it 
		-- (if you're an end-user reading this, using sudo is cheating and can cause bugs, so. please don't)
			from~=s8.board.deck and -- don't take from deck! that's what pull is for
			((from~=s8.board.stack and not from.home) or amt==1) and -- don't take more than one from the stack, or from a home
			#from~=0 and -- stop if source is empty
			(ens(from[#from-amt+1]).seen) and -- stop if pickup card is flipped
			(#to==0 or (ens(to[#to]).seen)) and -- continue if the area is empty or its top card is seen 
			( -- main logic
				(#to==0 or (
					((ens(from[#from-amt+1]).rank-1)==s8.sc[ens(to[#to]).rank]) ) -- check if destination rank is 1 less than pickup card's rank
				) and ( 
					not to.home and (s8.sc[ens(from[#from-amt+1]).suit]-1)%4==(s8.sc[ens(to[#to]).suit]) -- non-home suit checks for previous suit color in order 
					or to.home==ens(from[#from-amt+1]).suit -- home suit checks for the same suit
				)
			)
		)
	then
		local function take(source,cache,amount) -- taken table is flipped in cache but that's fine because we do it twice
			for i=1,amount do
				table.insert(cache,source[#source])
				table.remove(source)
			end
		end
		local t = {}
		take(from,t,amt)
		local l = #t
		take(t,to,l)
	else
		print('Illegal move!')
		print(from,to,amt)
	end
	s8.update()
end

s8.update = function()
	if not s8.initialized then return end
	local t
	for i=1,10 do
		t = s8.board[i]
		if t and #t~=0 then
			t[#t].seen = true
		end
	end
	for area in string.gmatch('Spades,Hearts,Clubs,Diamonds,Wands,Cups,Shields,Fleurons,stack','[^,]+') do 
		t = s8.board[area] -- this is just to make sure
		for _,card in ipairs(t) do --ipairs() doesnt touch non-numerically indexed values here
			card.seen = true
		end	
	end
	s8.view()
end

s8.pull = function()
	if #s8.board.deck==0 then
		if #s8.board.stack~=0 then
			s8.move(s8.board.stack,s8.board.deck,#s8.board.stack)
			for _,v in ipairs(s8.board.deck) do
				v.seen = false
			end
		end
	else -- #stack could be 0 so be careful
		s8.move(s8.board.deck,s8.board.stack,1,math.pi)
	end
end

s8.init = function()
	s8.initialized=false
	s8.board = {['deck']={},['stack']={}}
	for _,suit in ipairs(s8.suits) do
		s8.board[suit]={['home']=suit}
		local sr
		for rank=1,13 do
			table.insert(s8.board.deck,{['rank']=rank,['suit']=suit,['seen']=false})
		end
	end
	local t = s8.board.deck
	math.randomseed(os.time())
	for _=1,#t do
		for i = #t, 1, -1 do
			local j = math.random(i)
			t[i], t[j] = t[j], t[i]
		end
	end
	for i=1,10 do
		s8.board[i]={}
		s8.move(s8.board.deck,s8.board[i],i,math.pi)
		s8.board[i][i].seen=true
	end
	s8.initialized=true
	s8.pull()
end


s8.abbrs = {['Spades']='Sp',['Hearts']='Ht',['Clubs']='Cl',['Diamonds']='Dm',['Wands']='Wn',['Cups']='Cu',['Shields']='Sh',['Fleurons']='Fl'}
s8.abbrr = {'A','2','3','4','5','6','7','8','9','T','J','Q','K'}
s8.view = function()
	local function vis(card)
		if card==nil then return '   ' end
		return card.seen and s8.abbrs[card.suit]..s8.abbrr[card.rank] or '???'
	end
	local function tvis(cardstack)
		local card = {['seen']=false}
		if #cardstack==0 then 
			if cardstack.home then return s8.abbrs[cardstack.home]..'_'
			else return '___' end
		else card = cardstack[#cardstack] end
		return vis(card)
	end
	local header = {tvis(s8.board.deck),tvis(s8.board.stack)}
	for _,v in ipairs(s8.suits) do
		table.insert(header,tvis(s8.board[v]))
	end
	print(table.concat(header,' '))
	local height = 1
	for i=1,10 do
		height = math.max(height,#s8.board[i])
	end
	for i=1,height do
		local t={}
		for j=1,10 do
			table.insert(t,vis(s8.board[j][i]))
		end
		print(table.concat(t,' '))
	end
end

s8.helptext = {
	['help'] = "Shows helptext for a command.",
	['colors'] = "Shows the order in which each suit stacks on top of each other.",
	['view'] = "Shows the board. Automatically run every turn.",
	['pull'] = "Pulls a card from the deck to the stack, or refreshes if the deck's empty.",
	['move'] = [[Attempts to move n cards from f to t.
If only one argument is given, instead attempts to
move a card from the stack to the given area.
Example: s8.move(1,'Spades') attempts to move
the top card of stack 1 to the Spades home.]],
	['init'] = "Restarts the game. Use if you're stuck."
}

s8.colors = function()
	print([['Black → Red → Blue → Yellow → Black'
	Black: Spades, Wands
	Red: Hearts, Cups
	Blue: Clubs, Shields
	Yellow: Diamonds, Fleurons]])
end

s8.help = function(cmd)
	if not cmd then print([[
Funcs: s8.help(), s8.colors(), s8.view(), s8.pull(), s8.init(), s8.move([f,t,n?]/[t])
For help with a command (e.g. s8.move), type s8.help('move')]])
	else 
		print(s8.helptext[cmd]) 
	end
end
s8.init()
s8.help()