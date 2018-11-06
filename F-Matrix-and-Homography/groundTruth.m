function [F0] = groundTruth(MextLeft, MextRight, MintLeft, MintRight)


piLeft  =  MintLeft * MextLeft;
piRight =  MintRight * MextRight;

m = null(piRight);
temp = piLeft * m;





crossMatrix = [0 -temp(3) temp(2) ; temp(3) 0 -temp(1) ; -temp(2) temp(1) 0 ];



F0 = crossMatrix  *  piLeft * piRight.'  * inv( piRight * piRight.' );




end

