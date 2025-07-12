const express = require('express');
const app = express();
const port = 3000;
const { spawn } = require('child_process');

app.use(express.json());
app.use(express.static('.'));

let comandosProlog = '';

app.post('/asignar', (req, res) => {
  const { curso, dia, turno } = req.body;
  const nuevoHecho = `assertz(curso_disponible('${curso}', '${dia}', '${turno}')).\n`;
  comandosProlog += nuevoHecho;

  const prolog = spawn('swipl', ['-q']);
  const query = `
    consult('base.pl'),
    ${comandosProlog}
    asignar,
    mostrar_asignaciones,
    profesores_sin_asignar,
    halt.
  `;

  let salida = '';

  prolog.stdin.write(query);
  prolog.stdin.end();

  prolog.stdout.on('data', data => salida += data.toString());
  prolog.stderr.on('data', err => console.error('Error Prolog:', err.toString()));

  prolog.on('close', () => {
    const asignados = [];
    const noAsignados = [];
    const asignacionesPorCurso = {};
    const mensajes = [];

    salida.split('\n').forEach(linea => {
      const clean = linea.trim();

      if (clean.startsWith('asignado:')) {
        const [, profesor, curso, dia, turno] = clean.split(':');
        asignados.push(`✅ ${profesor} - ${curso} (${dia}, ${turno})`);

        const clave = `${curso}-${dia}-${turno}`;
        if (!asignacionesPorCurso[clave]) {
          asignacionesPorCurso[clave] = [];
        }
        asignacionesPorCurso[clave].push(profesor);
      } else if (clean.startsWith('no_asignado:')) {
        const [, profesor] = clean.split(':');
        noAsignados.push(`❌ ${profesor}`);
      } else if (clean.startsWith('mensaje:')) {
        const mensaje = clean.replace('mensaje:', '').trim();
        mensajes.push(`📌 ${mensaje}`);
      }
    });

    const cursoActual = `${curso}-${dia}-${turno}`;
    if (!asignacionesPorCurso[cursoActual] || asignacionesPorCurso[cursoActual].length === 0) {
      mensajes.push(`⚠️ No hay profesores disponibles para ${curso} el ${dia} en el turno ${turno}.`);
    }

    const respuesta = `
      ${mensajes.map(m => `<p><strong>${m}</strong></p>`).join('')}
      <h2>Profesores Asignados</h2>
      ${asignados.length > 0 ? `<ul>${asignados.map(p => `<li>${p}</li>`).join('')}</ul>` : '<p>Sin asignaciones</p>'}
      <h2>Profesores No Asignados</h2>
      ${noAsignados.length > 0 ? `<ul>${noAsignados.map(p => `<li>${p}</li>`).join('')}</ul>` : '<p>Todos asignados</p>'}
    `;

    res.send(respuesta);
  });
});

app.get('/cursos', (req, res) => {
  const prolog = spawn('swipl', ['-q', '-s', 'base.pl', '-g', 'listar_cursos', '-t', 'halt']);

  let salida = '';
  prolog.stdout.on('data', data => salida += data.toString());
  prolog.stderr.on('data', err => console.error('Error Prolog:', err.toString()));

  prolog.on('close', () => {
    const cursos = salida.split('\n')
      .filter(linea => linea.startsWith('curso:'))
      .map(linea => linea.replace('curso:', '').trim());
    res.json(cursos);
  });
});

app.listen(port, () => {
  console.log(`✅ Servidor corriendo en http://localhost:${port}`);
});


