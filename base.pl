% --- HECHOS ---
curso_profesor(juan, matematicas).
curso_profesor(juan, fisica).
curso_profesor(maria, quimica).
curso_profesor(maria, negocios).
curso_profesor(pedro, quimica).
curso_profesor(luisa, biologia).
curso_profesor(laura, biologia).
curso_profesor(ana, ingles).
curso_profesor(carlos, matematicas).
curso_profesor(sofia, fisica).
curso_profesor(ricardo, ingles).
curso_profesor(ricardo, negocios).
curso_profesor(diego, biologia).
curso_profesor(diego, fisica).
%-- CASOS DOBLE ---
curso_profesor(zoe, algoritmos).
curso_profesor(bruno, algoritmos).
curso_profesor(alicia, historia).
curso_profesor(beto, historia).
curso_profesor(carla, computacion).
curso_profesor(diego, computacion).

% --- DISPONIBILIDAD ---
disponibilidad_profesor(juan, lunes, manana).
disponibilidad_profesor(juan, viernes, noche).
disponibilidad_profesor(maria, lunes, tarde).
disponibilidad_profesor(maria, martes, noche).
disponibilidad_profesor(pedro, lunes, tarde).
disponibilidad_profesor(pedro, miercoles, noche).
disponibilidad_profesor(luisa, martes, tarde).
disponibilidad_profesor(luisa, viernes, noche).
disponibilidad_profesor(laura, jueves, tarde).
disponibilidad_profesor(laura, miercoles, noche).
disponibilidad_profesor(ana, miercoles, manana).
disponibilidad_profesor(ana, martes, noche).
disponibilidad_profesor(carlos, lunes, manana).
disponibilidad_profesor(carlos, jueves, noche).
disponibilidad_profesor(sofia, martes, tarde).
disponibilidad_profesor(sofia, viernes, noche).
disponibilidad_profesor(ricardo, lunes, tarde).
disponibilidad_profesor(ricardo, jueves, noche).
%-- CASOS DOBLE ---
disponibilidad_profesor(diego, lunes, manana).
disponibilidad_profesor(diego, lunes, noche).
disponibilidad_profesor(zoe, jueves, tarde).
disponibilidad_profesor(zoe, viernes, noche).
disponibilidad_profesor(bruno, jueves, tarde).
disponibilidad_profesor(bruno, viernes, noche).
disponibilidad_profesor(alicia, miercoles, tarde).
disponibilidad_profesor(beto, miercoles, tarde).
disponibilidad_profesor(carla, viernes, manana).
disponibilidad_profesor(diego, viernes, manana).

% --- HECHOS DINÁMICOS ---
:- dynamic curso_disponible/3.
:- dynamic asignado/4.

% --- ASIGNACIÓN ---
asignar :-
    forall(curso_disponible(Curso, Dia, Turno), (
        findall(Profesor,
            (
                curso_profesor(Profesor, Curso),
                disponibilidad_profesor(Profesor, Dia, Turno),
                \+ asignado(_, Dia, Turno, Curso),
                \+ asignado(Profesor, Dia, Turno, _)
            ),
            Profesores),
        sort(Profesores, Ordenados),
        asignar_lista(Ordenados, Dia, Turno, Curso)
    )).

asignar_lista([], _, _, _) :- !.
asignar_lista([P|Resto], Dia, Turno, Curso) :-
    \+ asignado(P, Dia, Turno, Curso),
    assertz(asignado(P, Dia, Turno, Curso)),
    ( Resto \= [] ->
        format('mensaje:Se asignó primero a ~w por orden alfabético para ~w.~n', [P, Curso])
    ; true ).

% --- MOSTRAR ASIGNACIONES ---
mostrar_asignaciones :-
    forall(asignado(Profesor, Dia, Turno, Curso),
        format('asignado:~w:~w:~w:~w~n', [Profesor, Curso, Dia, Turno])).

% --- MOSTRAR NO ASIGNADOS (sin duplicados) ---
profesores_sin_asignar :-
    setof(Profesor, C^curso_profesor(Profesor, C), Todos),
    forall(member(Profesor, Todos), (
        (   \+ asignado(Profesor, _, _, _)
        ->  format('no_asignado:~w~n', [Profesor])
        ;   true)
    )).

% --- LISTAR CURSOS SIN REPETIR ---
listar_cursos :-
    setof(Curso, Profesor^curso_profesor(Profesor, Curso), Lista),
    forall(member(C, Lista),
        format('curso:~w~n', [C])).
