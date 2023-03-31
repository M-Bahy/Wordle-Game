is_category(C):- 
	category(C).
	
categories(L):- 
	setof(C,category(C),L).
	
available_length(L):- 
	word(W,_), 
	string_length(W,L).
	
pick_word(W,L,C) :- 
	word(W,C), 
	string_length(W,L).
	
correct_letters(L1,L2,CL):-
	intersection(L1, L2, L),
	remove_duplicates(L, CL).

remove_duplicates([],[]).
remove_duplicates([H|T],L):-
	member(H,T),
	remove_duplicates(T,L).
remove_duplicates([H|T],[H|LT]):-
	\+member(H,T),
	remove_duplicates(T,LT).
	
correct_positions([], [], []).
correct_positions([H|T1], [H|T2], [H|T3]):-
	correct_positions(T1,T2,T3).
correct_positions([H1|T1], [H2|T2], Pl):- 
	H1\=H2,
	correct_positions(T1,T2,Pl).
	
build_kb:- 
	write("Welcome to Pro-Wordle!"),nl,
	write("--------------------------------"),nl,nl,
	bahy.
	
bahy:-
	write("Please enter a word and its category on separate lines:"),nl,
	read(W),
	(
	(W=done,nl,nl,write("Done building the words database..."),nl);
	(W\=done,nl,read(C),assert(category(C)),assert(word(W,C)),nl,bahy)
	).
	
play:-
	write("The available categories are: "),
	categories(L),
	write(L),nl,nl,
	bahy3,
	bahy2,nl,nl,
	g(L1),
	mg(L1).
	
bahy3:- 
	write("Choose a category: "),nl,
	read(C),
	(
		(is_category(C),!,assert(cans(C)));
		(nl,write("This category does not exist."),nl,bahy3)
	).
	
bahy2:- 
	cans(C),
	write("Choose a length: "),nl,
	read(L),
	(
		(
			setof(Ww,pick_word(Ww,L,C),Wt),
			random_member(W,Wt),
			assert(wans(W)),
			string_chars(W,Wl), 
			assert(las(Wl)),
			assert(lenans(L)),nl,
			write("Game started. You have "),
			L1 is L+1,
			write(L1),
			assert(g(L1)),
			write(" guesses.")
		);
		(
			\+pick_word(W,L,C),nl,
			write("There are no words of this length."),nl,
			bahy2
		)
	).
	
mg(L1) :-
	promt,
	tryial(T), 
	string_chars(T,L),
	wans(A),
	las(Wl),
	(   
		(
			L1=1,T\=A,nl,write("You lost!")
		);   
		(
			T=A,nl,write("You Won!")
		);    
		(
			nl, write("Correct letters are: "),
			correct_letters(L,Wl,Cl),
			write(Cl),nl,
			write("Correct letters in correct positions are: "),
			(correct_positions(L,Wl,Pl),write(Pl),nl),
			L2 is L1-1,
			retract(g(L1)),
			assert(g(L2)),
			write("Remaining Guesses are "),
			write(L2),nl,
			retract(tryial(T)),nl,
			mg(L2)
		)
	).
	
promt:-
	write("Enter a word composed of "),
	lenans(L5),
	write(L5),
	write(" letters:"),nl,
	read(T),
	string_length(T,J),
	(
		(
			J=L5,
			word(T,_),
			assert(tryial(T))
		);
		(
			J=L5,
			\+word(T,_),
			write("Word is not in the knowledge base. Try again."),nl,
			g(L1),
			write("Remaining Guesses are "),
			write(L1),nl,
			promt
		);
		(
			J\=L5,nl,
			write("Word is not composed of "),
			write(L5),
			write(" letters. Try again."),nl,
			g(L1),
			write("Remaining Guesses are "),
			write(L1),nl,
			promt
		)
	).
	
main:- 
	build_kb,nl,
	play,
	retractall(category(_)),
	retractall(word(_,_)),
	retractall(cans(_)),
	retractall(wans(_)),
	retractall(las(_)),
	retractall(lenans(_)),
	retractall(g(_)),
	retractall(tryial(_)).
