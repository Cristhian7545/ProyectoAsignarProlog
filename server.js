const express = require('express');
const app = express();
const port = 3000;
const { spawn } = require('child_process');

app.use(express.json());
app.use(express.static('.'));

let comandosProlog = ''; // Acumulador

app.post('/asignar', (req, res) => {
  const { curso, dia, turno } = req.body;
  const nuevoHecho = `assertz(curso_disponible(${curso}, ${dia}, ${turno})).\n`;
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

    salida.split('\n').forEach(linea => {
      const clean = linea.trim();
      if (clean.startsWith('asignado:')) {
        const [, profesor, curso, dia, turno] = clean.split(':');
        asignados.push(`✅ ${profesor} - ${curso} (${dia}, ${turno})`);
      } else if (clean.startsWith('no_asignado:')) {
        const [, profesor] = clean.split(':');
        noAsignados.push(`❌ ${profesor}`);
      }
    });

    const respuesta = `
      <h2>Profesores Asignados</h2>
      <ul>${asignados.map(p => `<li>${p}</li>`).join('')}</ul>
      <h2>Profesores No Asignados</h2>
      <ul>${noAsignados.map(p => `<li>${p}</li>`).join('')}</ul>
    `;
    res.send(respuesta);
  });
});

app.listen(port, () => {
  console.log(`Servidor corriendo en http://localhost:${port}`);
});
