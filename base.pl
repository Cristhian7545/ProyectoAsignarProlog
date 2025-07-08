% Profesores: nombre, [cursos], [disponibilidad(dia, turno)]
profesor(juan, [matematicas, fisica], [disp(lunes, manana), disp(martes, tarde)]).
profesor(maria, [quimica, biologia], [disp(lunes, tarde), disp(jueves, tarde)]).
profesor(pedro, [quimica], [disp(lunes, tarde), disp(martes, manana)]).
profesor(luisa, [biologia], [disp(martes, tarde), disp(miercoles, tarde)]).
profesor(laura, [biologia], [disp(jueves, tarde)]).
profesor(ana, [ingles], [disp(miercoles, manana), disp(viernes, tarde)]).
profesor(carlos, [matematicas], [disp(lunes, manana), disp(jueves, tarde)]).
profesor(sofia, [fisica], [disp(martes, tarde), disp(miercoles, manana)]).
profesor(ricardo, [ingles, quimica], [disp(lunes, tarde), disp(martes, tarde)]).
profesor(diego, [biologia, fisica], [disp(lunes, manana), disp(miercoles, tarde)]).

:- dynamic curso_disponible/3.
:- dynamic asignado/4.

asignar :-
    curso_disponible(Curso, Dia, Turno),
    profesor(Profesor, Cursos, Disponibilidad),
    member(Curso, Cursos),
    member(disp(Dia, Turno), Disponibilidad),
    \+ asignado(_, Dia, Turno, Curso),  
    \+ asignado(Profesor, _, _, _),     
    assertz(asignado(Profesor, Dia, Turno, Curso)),
    fail.
asignar.

mostrar_asignaciones :-
    forall(asignado(Profesor, Dia, Turno, Curso),
           format('asignado:~w:~w:~w:~w~n', [Profesor, Curso, Dia, Turno])).

profesores_sin_asignar :-
    forall((profesor(Nombre, _, _), \+ asignado(Nombre, _, _, _)),
           format('no_asignado:~w~n', [Nombre])).
