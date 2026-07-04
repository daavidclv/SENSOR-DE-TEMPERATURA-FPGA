# 🌡️ Sensor de Temperatura sobre FPGA

Sistema de adquisición y procesado de señal de temperatura implementado en VHDL sobre FPGA.

## 📋 Descripción

Diseño digital completo en VHDL que lee, convierte y muestra en display la medida de un sensor de temperatura conectado por SPI. El sistema incluye filtrado de pulsadores para la interacción del usuario y gestión de la interfaz de medida, siguiendo una arquitectura modular típica de diseño digital síncrono.

## 🛠️ Stack técnico

- **Lenguaje:** VHDL
- **Simulación/verificación:** ModelSim (testbench incluido)
- **Comunicación con el sensor:** SPI

## 📁 Módulos principales

| Archivo | Función |
|---|---|
| `interfaz_medt.vhd` | Interfaz de medida principal |
| `control_spi.vhd` | Control del bus SPI hacia el sensor |
| `conversor_temp.vhd` | Conversión de la lectura a temperatura |
| `displays.vhd` | Control de displays de 7 segmentos |
| `reg_sdi.vhd` | Registro de entrada serie |
| `gen_sc.vhd` | Generador de señal de reloj/control |
| `filtro_pulsadores.vhd` | Antirrebotes de pulsadores físicos |
| `gestor_pulsador.vhd` | Gestión de eventos de pulsador |
| `test_interfaz_medt.vhd.vhd` | Testbench de verificación en ModelSim |

## ⚙️ Verificación

El diseño se verificó mediante simulación en ModelSim usando el testbench `test_interfaz_medt.vhd.vhd` antes de la síntesis sobre FPGA.

## 📄 Documentación adicional

`MEM_PROYECTOB2_DDII.pdf` — memoria técnica completa del proyecto con el diagrama de bloques y las decisiones de diseño.

## 🎯 Lo más complejo del proyecto

- Diseño de una máquina de estados para gestionar la comunicación SPI de forma síncrona
- Filtrado robusto de entradas físicas (antirrebotes) en hardware

## 👤 Autor

David Calvo Heredero — [LinkedIn](https://www.linkedin.com/in/david-calvo-heredero-20b20a33a) · [GitHub](https://github.com/daavidclv)
