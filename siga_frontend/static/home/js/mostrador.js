(function () {
    const MENSAJE_VACIO_DEFECTO = 'No hay resultados con los filtros seleccionados';

    function obtenerValorCelda(fila, columna) {
        const celda = fila.children[columna];
        return celda ? celda.textContent.trim() : '';
    }
    function esFilaVacia(fila) {
        return fila.children.length === 1 && fila.children[0].hasAttribute('colspan');
    }
    function obtenerFilasOriginales(tbody) {
        if (!tbody._filasOriginales) {
            tbody._filasOriginales = Array.from(tbody.querySelectorAll('tr')).filter(f => !esFilaVacia(f));
        }
        return tbody._filasOriginales;
    }
    function limpiarFilaVacia(tbody) {
        const filaVacia = tbody.querySelector('tr[data-fila-vacia]');
        if (filaVacia) filaVacia.remove();
    }
    function insertarFilaVacia(tbody, mensaje, colspan) {
        limpiarFilaVacia(tbody);
        const tr = document.createElement('tr');
        tr.setAttribute('data-fila-vacia', '');
        const td = document.createElement('td');
        td.setAttribute('colspan', colspan);
        td.style.textAlign = 'center';
        td.style.color = '#9CA3AF';
        td.style.padding = '20px';
        td.textContent = mensaje;
        tr.appendChild(td);
        tbody.appendChild(tr);
    }
    function aplicarFiltros(tbody) {
        const selects = document.querySelectorAll(
            `[data-mostrador][data-mostrador-target="${tbody.id}"]`
        );
        const criterios = [];
        let mensajeVacio = MENSAJE_VACIO_DEFECTO;

        selects.forEach(select => {
            if (!select.value) return;
            const columna = parseInt(select.dataset.mostradorColumna, 10) || 0;
            criterios.push({ columna, valor: select.value.toLowerCase() });

            const opcion = select.options[select.selectedIndex];
            if (opcion && opcion.dataset.mostradorVacio) {
                mensajeVacio = opcion.dataset.mostradorVacio;
            }
        });

        const filas = obtenerFilasOriginales(tbody);
        if (filas.length === 0) return;

        let visibles = 0;
        const colspanRef = filas[0].children.length;

        filas.forEach(fila => {
            const cumple = criterios.every(
                c => obtenerValorCelda(fila, c.columna).toLowerCase() === c.valor
            );
            fila.style.display = cumple ? '' : 'none';
            if (cumple) visibles++;
        });

        if (visibles === 0 && criterios.length > 0) {
            insertarFilaVacia(tbody, mensajeVacio, colspanRef);
        } else {
            limpiarFilaVacia(tbody);
        }
    }
    function iniciar() {
        document.querySelectorAll('[data-mostrador]').forEach(select => {
            select.addEventListener('change', () => {
                const tbody = document.getElementById(select.dataset.mostradorTarget);
                if (tbody) aplicarFiltros(tbody);
            });
        });
    }
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', iniciar);
    } else {
        iniciar();
    }
})();