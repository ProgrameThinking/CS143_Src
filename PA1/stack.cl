(*
 *  CS164 Fall 94
 *
 *  Programming Assignment 1
 *    Implementation of a simple stack machine.
 *
 *  Skeleton file
 *)

class Main inherits IO {

    stack : List <- new List;
    input : String;
    a : Int;
    b : Int;
    s1 : String;
    s2 : String;

    transfer : A2I <- new A2I;

    isFinish(str : String ) : Bool {

        if str = "x" then false
        else true
        fi
    };

    print_list(l : List) : Object {
        if l.isNil() then 0 else
        if l.head()="#" then 0
        else {
            out_string(l.head());
            out_string("\n");
            print_list(l.tail());
        }
        fi fi
    };

    evaluate(sta : List): List {
        {
            if sta.head() = "+" then {
                sta <- sta.tail();
                a <- transfer.a2i_aux(sta.head());
                sta <- sta.tail();
                b <- transfer.a2i_aux(sta.head());
                sta <- sta.tail();
                sta <- sta.cons(transfer.i2a_aux(a+b));
            }
            else if sta.head() = "s" then {
                sta <- sta.tail();
                s1 <- sta.head();
                sta <- sta.tail();
                s2 <- sta.head();
                sta <- sta.tail();
                sta <- sta.cons(s1);
                sta <- sta.cons(s2);
            }
            else 0
            fi fi;
            sta;
        }
    };

    main(): Object {

        {
            out_string("> ");
            input <- in_string();
            stack <- stack.cons("#");
            while isFinish(input) loop
            {
                if input = "d" then print_list(stack) else
                if input = "e" then stack <- evaluate(stack) else 
                stack <- stack.cons(input)
                fi fi;
                out_string("> ");
                input <- in_string();
            }
            pool;
        }
    };
};