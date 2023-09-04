C
C      ________________________________________________________
C     |                                                        |
C     |                     SOLVE F(X) = 0.                    |
C     |                                                        |
C     |    INPUT:                                              |
C     |                                                        |
C     |      Y,Z   --STARTING GUESS CHOSEN SO THAT F(Y)*F(Z)<0 |
C     |                                                        |
C     |      T     --TOLERANCE (ITERATIONS CONTINUE UNTIL      |
C     |                 THE ERROR IN THE ROOT IS .LE. T        |
C     |                                                        |
C     |      F     --FUNCTION (EXTERNAL IN MAIN PROGRAM)       |
C     |                                                        |
C     |    OUTPUT:                                             |
C     |                                                        |
C     |      ROOT  --SOLUTION                                  |
C     |                                                        |
C     |    BUILTIN FUNCTIONS: ABS,AMAX1,SIGN,SQRT              |
C     |    PACKAGE SUBROUTINES: INP                            |
C     |________________________________________________________|
C
      FUNCTION ROOT(Y,Z,T,F)
      REAL A,B,C,D,E,F,FL,FR,L,P,Q,R,S,T,U,V,W,Y,Z
      REAL D2,D3,D4,FA,FB,FC,FD,P2,P3,P4,D34,D42,D23
      L = Y
      R = Z
      IF ( L .LE. R ) GOTO 10
      A = L
      L = R
      R = A
10    FL = F(L)
      FR = F(R)
      IF ( SIGN(FL,FR) .EQ. FL ) GOTO 220
      Q = FL/ABS(FL)
C     -----------------------------------
C     |*** COMPUTE MACHINE PRECISION ***|
C     -----------------------------------
      S = T + T
      U = 1.
20    U = .5*U
      A = 1. + U
      IF ( A .GT. 1. ) GOTO 20
      U = 5.*U
      V = .5*U
30    E = R - L
      IF ( E .LE. S ) GOTO 210
      IF ( E .LE. U*(ABS(L)+ABS(R)) ) GOTO 210
      IF ( ABS(FL) .GT. ABS(FR) ) GOTO 40
      A = L
      FA = FL
      B = R
      FB = FR
      GOTO 50
40    A = R
      FA = FR
      B = L
      FB = FL
C     ---------------------
C     |*** SECANT STEP ***|
C     ---------------------
50    C = A - FA*(A-B)/(FA-FB)
      P = C
      W = AMAX1(T,V*(ABS(L)+ABS(R)))
      IF ( ABS(C-L) .LT. W ) C = L + W
      IF ( ABS(C-R) .LT. W ) C = R - W
      FC = F(C)
      IF ( SIGN(FC,Q) .EQ. FC ) GOTO 60
      R = C
      FR = FC
      GOTO 70
60    L = C
      FL = FC
70    W = R - L
      IF ( W .LE. S ) GOTO 250
      IF ( W .LE. U*(ABS(L)+ABS(R)) ) GOTO 250
      IF ( ABS(FC) .GE. ABS(FB) ) GOTO 90
      IF ( ABS(FC) .GT. ABS(FA) ) GOTO 80
      W = C
      C = B
      B = A
      A = W
      W = FC
      FC = FB
      FB = FA
      FA = W
      GOTO 90
80    W = C
      C = B
      B = W
      W = FC
      FC = FB
      FB = W
90    IF ( A .LT. L ) GOTO 190
      IF ( A .GT. R ) GOTO 190
C     --------------------------------------
C     |*** QUADRATIC INTERPOLATION STEP ***|
C     --------------------------------------
      CALL INP(D,A,B,C,FA,FB,FC,L,R)
C     ------------------------------------
C     |*** APPLY PSEUDO-NEWTON METHOD ***|
C     ------------------------------------
100   P = D
      W = AMAX1(T,V*(ABS(L)+ABS(R)))
      IF ( ABS(L-D) .LT. W ) GOTO 110
      IF ( ABS(R-D) .GT. W ) GOTO 130
110   IF ( D+D .GT. L+R ) GOTO 120
      D = L + W
      GOTO 130
120   D = R - W
130   IF ( D .LE. L ) GOTO 190
      IF ( D .GE. R ) GOTO 190
      E = .5*E
      IF ( E .LT. ABS(A-D) ) GOTO 190
      FD = F(D)
      IF ( SIGN(FD,Q) .EQ. FD ) GOTO 140
      R = D
      FR = FD
      GOTO 150
140   L = D
      FL = FD
150   W = R - L
      IF ( W .LE. S ) GOTO 250
      IF ( W .LE. U*(ABS(L)+ABS(R)) ) GOTO 250
      W = ABS(FD)
      IF ( W .LE. ABS(FA) ) GOTO 170
      IF ( W .LE. ABS(FB) ) GOTO 160
      IF ( W .GE. ABS(FC) ) GOTO 180
      W = D
      D = C
      C = W
      W = FD
      FD = FC
      FC = W
      GOTO 180
160   W = D
      D = C
      C = B
      B = W
      W = FD
      FD = FC
      FC = FB
      FB = W
      GOTO 180
170   W = D
      D = C
      C = B
      B = A
      A = W
      W = FD
      FD = FC
      FC = FB
      FB = FA
      FA = W
180   D4 = D - A
      D3 = C - A
      D2 = B - A
      D34 = C - D
      D42 = D - B
      D23 = B - C
      P2 = 0.
      P3 = 0.
      P4 = 0.
      IF ( D34 .NE. 0. ) P2 = 1./D34
      IF ( D42 .NE. 0. ) P3 = 1./D42
      IF ( D23 .NE. 0. ) P4 = 1./D23
      P2 = (FB-FA)/(D2*(1.+(D2/D3)*P2*D42+(D2/D4)*P2*D23))
      P3 = (FC-FA)/(D3*(1.+(D3/D2)*P3*D34+(D3/D4)*P3*D23))
      P4 = (FD-FA)/(D4*(1.+(D4/D2)*P4*D34+(D4/D3)*P4*D42))
      P2 = P2 + P3 + P4
      IF ( P2 .EQ. 0. ) GOTO 190
      D = A - FA/P2
      GOTO 100
C     --------------------------
C     |*** BISECTION METHOD ***|
C     --------------------------
190   D = .5*(L+R)
      FD = F(D)
      IF ( SIGN(FD,Q) .EQ. FD ) GOTO 200
      R = D
      FR = FD
      GOTO 30
200   L = D
      FL = FD
      GOTO 30
210   ROOT = .5*(L+R)
      RETURN
220   IF ( FL. EQ. 0. ) GOTO 230
      IF ( FR .EQ. 0. ) GOTO 240
      WRITE(6,*) 'ERROR: FUNCTION HAS SAME SIGN AT BOTH STARTING POINTS'
      STOP
230   ROOT = L
      RETURN
240   ROOT = R
      RETURN
250   IF ( P .LT. L ) GOTO 210
      IF ( P .GT. R ) GOTO 210
      ROOT = P
      RETURN
      END
C%
      SUBROUTINE INP(A,X,Y,Z,U,V,W,L,R)
      REAL A,B,C,L,P,Q,R,S,T,U,V,W,X,Y,Z
      S = Z - X
      T = (Y-X)/S
      A = (U-V)/T + (W-V)/(1.-T)
      IF ( A .EQ. 0. ) GOTO 40
      B = .5*(W-U)/A - .5
      C = U/A
      T = SQRT(ABS(C))
      IF ( ABS(B) .LT. SIGN(T,C) ) GOTO 60
      T = AMAX1(T,ABS(B))
      IF ( T .EQ. 0. ) GOTO 50
      Q = 1./T
      P = SQRT((Q*B)**2 - Q*C*Q)
      P = T*P
      IF ( ABS(P+B) .GT. ABS(P-B) ) GOTO 10
      Q = P - B
      GOTO 20
10    Q = -(B+P)
20    P = C/Q
      Q = X + S*Q
      P = X + S*P
      IF ( Q .LT. L ) GOTO 30
      IF ( Q .GT. R ) GOTO 30
      A = Q
      RETURN
30    A = P
      RETURN
40    IF ( U .EQ. W ) GOTO 50
      A = X + S*U/(U-W)
      RETURN
50    A = L
      RETURN
60    A = X - S*B
      RETURN
      END