.import _init

.segment "VECTORS"

.addr 0 ;your NMIB handler here
.addr _init
.addr 0 ;your IRQB handler here