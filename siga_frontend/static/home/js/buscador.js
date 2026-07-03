(function () {
    'use strict';

    function normalizarTexto(texto) {
        return (texto || '')
            .toLowerCase()
            .normalize('NFD')
            .replace(/[\u0300-\u036f]/g, '')
    }

    function obtenerTextoFila(fila, columnas) {
        const celdas = fila.querySelectorAll('td');
        if (!columnas || columnas.length === 0) {
            return normalizarTexto(fila.textContent);
        }
        let texto = '';
        columnas.forEach(indice => {
            if (celdas[indice]) {
                texto += celdas[indice].textContent + '';
            }
        });
        return normalizarTexto(texto);
    }

    function inicializarBuscador(input) {
        const tbodyId = input.dataset.buscadorTarget;
        const tbody = document.getElementById(tbodyId);

        if (!tbody) {
            console.warn(`buscador.js: tbody con ID "${tbodyId}" no encontrado`);
            return;
        }

        const colspan = input.dataset.buscadorColspan || '4';
        const columnasAttr = input.dataset.buscadorColumnas;
        const columnas = columnasAttr 
            ? columnasAttr.split(',').map(n => parseInt(n.trim(), 10))
            : null;

        const idFilaVacia = `filaSinResultados__${tbodyId}`;

        input.addEventListener('input', function (e) {
            const filtro = normalizarTexto(e.target.value.trim());
            const filas = tbody.querySelectorAll('tr');
            let visibles = 0;

            filas.forEach(fila => {
                if (fila.id === idFilaVacia || fila.querySelector('td[colspan]')) {
                    return;
                }

                const textoFila = obtenerTextoFila(fila, columnas);
                const coincide = textoFila.includes(filtro);
                fila.style.display = coincide ? '' : 'none';
                if (coincide) visibles++;
            });

            actualizarMensajeSinResultados(tbody, idFilaVacia, colspan, visibles, filtro);
        });
    }

    function actualizarMensajeSinResultados(tbody, idFilaVacia, colspan, visibles, filtro) {
        let filaVacia = document.getElementById(idFilaVacia);

        if (visibles === 0 && filtro !== '') {
            if (!filaVacia) {
                filaVacia = document.createElement('tr');
                filaVacia.id = idFilaVacia;
                filaVacia.innerHTML = `<td colspan="${colspan}" style="text-align:center;">No se encontraron resultados que coincidan con "${filtro}" en esta página.</td>`;
                tbody.appendChild(filaVacia);
            } else {
                filaVacia.querySelector('td').textContent = `Resultados no encontrados con filtro "${filtro}".`;
                filaVacia.style.display = '';
            }
        } else if (filaVacia) {
            filaVacia.style.display = 'none';
        }
    }

    function iniciar() {
        document
            .querySelectorAll('input[data-buscador-target]')
            .forEach(inicializarBuscador);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', iniciar);
    } else {
        iniciar();
    }
})();