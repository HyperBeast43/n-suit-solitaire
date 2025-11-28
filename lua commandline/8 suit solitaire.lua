local s8 = {}
s8.sc = {['spades']=0,['hearts']=1,['clubs']=2,['diamonds']=3,['wands']=0,['cups']=1,['shields']=2,['fleurons']=3}
s8.suits = {'spades','hearts','clubs','diamonds','wands','cups','shields','fleurons'}

function s8.move(qfrom,qto,qamt,sudo)
	local ens = function(t)
		if t then return t else return {['rank']=0} end
	end
	local from = {['rank']=0}
	local to 
	local amt = 1
	from = qfrom or from 
	to = qto or to 
	amt = qamt or amt 
	amt = tonumber(amt) or amt
	from = tonumber(from) or from
	from = type(from)=='string' and string.lower(from) or from
	if type(from)=='number' or type(from)=='string' then from=s8.board[from] end -- `'key'` as shorthand for `s8.board['key']`
	if not to then to = from; from = s8.board.stack end -- move(area) as shorthand for move('stack',area)
	to = type(to)=='string' and string.lower(to) or to
	to = tonumber(to) or to
	if type(to)=='number' or type(to)=='string' then to=s8.board[to] end
	to = ens(to)
	local checkcard = ens(from[#from-amt+1])
	local destcard = ens(to[#to])
	local m4 = function(n,ofs) --prevent nil arithmetic
	  if n~=nil then return (n+(ofs or 0))%4 else return nil end
	end
	local achiral = (#to<2 or not ens(to[#to-1]).seen)
	local schiral = m4(s8.sc[checkcard.suit],2)==s8.sc[destcard.suit]
	local rchiraldest = m4(s8.sc[destcard.suit])==m4(s8.sc[ens(to[(#to)-1]).suit],1) and ens(to[#to-1]).seen
	local lchiraldest = m4(s8.sc[destcard.suit])==m4(s8.sc[ens(to[(#to)-1]).suit],-1) and ens(to[#to-1]).seen
	local rchiralcheck = m4(s8.sc[checkcard.suit],-1)==s8.sc[destcard.suit]
	local lchiralcheck = m4(s8.sc[checkcard.suit],1)==s8.sc[destcard.suit]
	local achiralcheck = false
	if amt>1 then --chiralchecks for moving more than one card
		rchiralcheck = rchiralcheck and m4(s8.sc[checkcard.suit],1)==s8.sc[ens(from[#from-amt+2])]
		lchiralcheck = lchiralcheck and m4(s8.sc[checkcard.suit],-1)==s8.sc[ens(from[#from-amt+2])]
		achiralcheck = m4(s8.sc[checkcard.suit],2)==s8.sc[ens(from[#from-amt+2])]
	end
	local chk_validchirality = (achiral or (rchiraldest and rchiralcheck) or (lchiraldest and lchiralcheck)) and not (schiral or achiralcheck)
	if 
		sudo or ( -- pull uses sudo to move from deck to stack, end-users shouldn't be able to use it because #args would be over 4)
			from~=to and -- source==dest edgecase 
			from~=s8.board.deck and -- don't take from deck! that's what pull is for
			((from~=s8.board.stack and not from.home and not to.home) or amt==1) and -- don't take more than one from the stack, or to/from a home
			#from~=0 and -- stop if source is empty
			(checkcard.seen) and -- stop if pickup card is flipped
			(#to==0 or (ens(to[#to]).seen)) and -- continue if the area is empty or its top card is seen 
			(to~=s8.board.stack) and -- do fucking NOT (unless you're sudoed)
			( -- main logic
				to.home and (
					to.home==checkcard.suit -- home suit checks for the same suit
					and ((#to==0 and checkcard.rank==1) or checkcard.rank==destcard.rank+1)  -- check if destination rank is 1 less than pickup card's rank, or if destination is empty
				) or (
					(chk_validchirality and checkcard.rank==destcard.rank-1) -- check if destination rank is 1 more (why does -1 work??) than pickup card's rank
					or (#to==0 and to.tableau) -- check if destination is empty and a valid tableau
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
		print('Dest. Chirality: '..(lchiraldest and 'Left' or (rchiraldest and 'Right' or 'None')))
		print('Tried Chirality: '..(schiral and 'Antipodal' or (rchiraldest and 'Right' or (lchiraldest and 'Left' or 'None'))))
		local fromstr 
		if from.home then 
			if #from==0 then fromstr = s8.abbrs[from.home]..'_'end
		end
		if not fromstr then
			fromstr = s8.vis(from[#from-amt+1],#from==0)
		end		
		local toaster -- hehe funy
		if to.home then 
			if #to==0 then toaster = s8.abbrs[to.home]..'_'end
		end
		if not toaster then
			toaster = s8.vis(to[#to],#to==0)
		end
		print(fromstr..' '..toaster..' '..tostring(amt))
	end
	s8.update()
end

function s8.what()
	print([[Chirality:
	Imagine the 4 base suits on a circle going clockwise, with Spades on top. 
	What direction around the circle something goes is its chirality.
	Sp->Ht goes right, and Sp->Dm goes left.
	Sp->Sp goes nowhere, so we say it has no chirality.
Antipodal: 
	Sp->Cl doesn't go nowhere, but Cl isn't left OR right of Sp. 
	Instead, where Sp->Cl lands is directly opposite its starting point.
	In this case, we say it has "antipodal" chirality.]])
end

function s8.update()
	if not s8.initialized then return end
	local t
	for i=1,10 do
		t = s8.board[i]
		if t and #t~=0 then
			t[#t].seen = true
		end
	end
	local wincheck = true
	for area in string.gmatch('spades,hearts,clubs,diamonds,wands,cups,shields,fleurons,stack','[^,]+') do 
		if area~=stack and #s8.board[area]~=13 then
			wincheck = false
		end
		t = s8.board[area] -- this is just to make sure everything's face-up
		for _,card in ipairs(t) do --ipairs() doesnt touch non-numerically indexed values here
			card.seen = true
		end	
	end
	if wincheck then print('Congratulations! You won!') end
	s8.view()
end

function s8.pull()
	if #s8.board.deck==0 then
		if #s8.board.stack~=0 then
			s8.move(s8.board.stack,s8.board.deck,#s8.board.stack,true)
			for _,v in ipairs(s8.board.deck) do
				v.seen = false
			end
			for i=1,floor(#s8.board.deck/2) do
			    s8.board.deck[i], s8.board.deck[#s8.board.deck+1-i] = s8.board.deck[#s8.board.deck+1-i], s8.board.deck[i]
			end
		end
	else
		s8.move(s8.board.deck,s8.board.stack,1,true)
	end
end

function s8.init()
	s8.initialized=false
	s8.board = {['deck']={},['stack']={}}
	for _,suit in ipairs(s8.suits) do
		s8.board[suit]={['home']=suit}
		local sr
		for rank=1,13 do
			table.insert(s8.board.deck,{['rank']=rank,['suit']=suit,['seen']=false})
		end
	end
	local shuffle = function (t) -- fisher-yates algorithm
		for i = #t, 2, -1 do
			local j = math.random(i)
			t[i], t[j] = t[j], t[i]
		end
	end
	math.randomseed(os.time())
	shuffle(s8.board.deck)
	for i=1,10 do
		s8.board[i]={['tableau']=true}
		s8.move(s8.board.deck,s8.board[i],i,true)
		s8.board[i][i].seen=true
	end
	s8.initialized=true
	s8.pull()
	print()
	s8.help()
	print()
	s8.guide()
end

function s8.vis(card,marked)
	if card==nil then return marked and '___' or '   ' end
	return card.seen and s8.abbrs[card.suit]..s8.abbrr[card.rank] or '???'
end

s8.abbrs = {['spades']='Sp',['hearts']='Ht',['clubs']='Cl',['diamonds']='Dm',['wands']='Wn',['cups']='Cu',['shields']='Sh',['fleurons']='Fl'}
s8.abbrr = {'A','2','3','4','5','6','7','8','9','T','J','Q','K'}
function s8.view()
	local function tvis(cardstack)
		local card = {['seen']=false}
		if #cardstack==0 then 
			if cardstack.home then return s8.abbrs[cardstack.home]..'_'
			else return '___' end
		else card = cardstack[#cardstack] end
		return s8.vis(card)
	end
	local header = {tvis(s8.board.deck),tvis(s8.board.stack)}
	for _,v in ipairs(s8.suits) do
		table.insert(header,tvis(s8.board[v]))
	end
	print()
	print(table.concat(header,' '))
	local height = 1
	for i=1,10 do
		height = math.max(height,#s8.board[i])
	end
	for i=1,height do
		local t={}
		for j=1,10 do
			table.insert(t,s8.vis(s8.board[j][i],i==1))
		end
		print(table.concat(t,' '))
	end
end

s8.helptext = {
	['help'] = "Shows helptext for a command.",
	['guide'] = "Shows the order in which each suit stacks on top of each other.",
	['what'] = "Shows definitions for terms one may be confused about.",
	['view'] = "Shows the board. Automatically run every turn.",
	['pull'] = [[Pulls a card from the deck to the stack. 
Refreshes the deck if the stack's empty.]], --Does nothing if the deck's empty, so be careful.]],
	['move'] = [[Attempts to move n cards from the second given area to the first.
If only one argument is given, instead attempts to
move a card from the stack to the given area.
Example: `move 1 spades` attempts to move
the frontmost card of tableau 1 to the spades home.]],
	['init'] = "Restarts the game. Use if you're stuck.",
	['exit'] = "Exits the program."
}

function s8.guide()
	print([[Black - Red - Blue - Yellow - Black
Suits can go forward or backward, 
but cannot switch directions. 
  Black: Spades, Wands
  Red: Hearts, Cups
  Blue: Clubs, Shields
  Yellow: Diamonds, Fleurons]])
end

function s8.help(cmd)
	if not cmd then print([[
Funcs: help [command?], exit, guide, view, pull, init, what, move [from, to, number?]/[to]
For help with a command (e.g. move), type help move]])
	else 
		print(s8.helptext[cmd]) 
	end
end

s8.init()

local cmd
while cmd~='exit' do
	print()
	print('Enter a command.')
	io.write('>')
	local inp = io.read()
	local args = {}
	for word in string.gmatch(inp, "([^%s]+)") do
		table.insert(args, word)
	end
	
	cmd = args[1]
	if not cmd or cmd=='exit' then goto continue end
	
	if not (s8[cmd] and type(s8[cmd]) == "function") 
	or (cmd=='move' and #args>4)
	or (cmd=='help' and #args>2)
	or (cmd~='move' and cmd~='help' and #args~=1) then
		print(cmd .. " is not a valid command or amount of arguments.")
		s8.help()
		goto continue
	else
		table.remove(args,1)
		s8[cmd](table.unpack(args))
	end
	::continue::
end