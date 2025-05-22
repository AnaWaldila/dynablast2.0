function F = root5d(x, equation, coefficient)
    double x
    F = double(subs(equation, coefficient, [x(1) x(2) x(3) x(4) x(5)]));
end