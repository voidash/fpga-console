use std::fs::OpenOptions;
use std::io::Read;
use std::io::Write;
use std::path::Path;

fn main() {
    let arg = std::env::args().nth(1).expect("Enter file");

    let path = Path::new(&arg);
    let mut file = OpenOptions::new()
        .read(true)
        .open(path)
        .expect("couldn't open file");

    let mut buf = String::new();

    file.read_to_string(&mut buf).unwrap();

    let tokenized_by_line = buf.split("\n").collect::<Vec<&str>>();

    println!("{:?}", tokenized_by_line);

    let tokenized_form = tokenized_by_line
        .iter()
        .map(|&val| {
            val.split(" ")
                .map(|x| String::from(x.to_uppercase()))
                .filter(|x| x != "")
                .collect::<Vec<String>>()
        })
        .collect::<Vec<Vec<String>>>();

    let mut hex_codes: Vec<u16> = Vec::new();

    for (i, tokens) in tokenized_form.iter().enumerate() {
        match &tokens[..] {
            [OP, REG, ADDR] => match &OP[..] {
                "LOAD" => {

                    match &REG[..] {
                        "A" => {
                            hex_codes.push(0b000);
                        }

                        "B" => {
                            hex_codes.push(0b0001);
                        }

                        _ => {
                            panic!(
                                "unknown register. Available Register are A and B on Line {}",
                                i
                            );
                        }
                    }
                }

                "LDI" => {

                    match &REG[..] {
                        "A" => {
                            hex_codes.push(0b1001);

                        }

                        "B" => {
                            hex_codes.push(0b1010);
                        }

                        _ => {
                            panic!(
                                "unknown register. Available Register are A and B on Line {}",
                                i
                            );
                        }
                    }
                }

                _ => {
                    panic!("unknown OPCODE on line {}", i);
                }
            },

            [OP, REG] => {

            let digit = u8::from_str_radix(&REG[..], 2)
                .expect("CLEAR needs an address");
                match &OP[..] {
                "CLEAR" => {
                    match &REG[..] {
                        "A" => {
                           hex_codes.push(0b0_000000_000000100);         
                        }
                        "B" => {
                           hex_codes.push(0b0_000000_000000010);         
                        }
                        "AC" => {
                           hex_codes.push(0b0_000000_000000001);         
                        }
                        "BTN1" => {
                           hex_codes.push(0b0_000000_000001000);         
                        }
                        "BTN2" => {
                           hex_codes.push(0b0_000000_000010000);         
                        }
                        "BTN3" => {
                           hex_codes.push(0b0_000000_000100000);         
                        }
                        "BTN4" => {
                           hex_codes.push(0b0_000000_001000000);         
                        }
                        "C" => {
                           hex_codes.push(0b0_000000_010000000);         
                        }
                        _ => {
                            panic!("{} Register doesn't exist for CLEAR type", REG);
                        }
                    }
                }
                "SUB" => {
                    match &REG[..] {
                        "A" => {
                          hex_codes.push(0b0_001000_000000100);         
                        }
                        "B" => {
                          hex_codes.push(0b0_001000_000000010);         
                        }
                        "C" => {
                          hex_codes.push(0b0_001000_000000001);         
                        }
                        
                        i if i.starts_with("#") =>  {
                            let digit = u16::from_str_radix(&i[1..], 10).expect("not a valid number");
                            hex_codes.push(0b1_001000_010000000);         
                            hex_codes.push(digit);
                        }

                        _ => {
                            panic!("invalid ADD command");
                        }
                    }
                }
                "ADD" => {
                    match &REG[..] {
                        "A" => {
                          hex_codes.push(0b0_000001_000000100);         
                        }
                        "B" => {
                          hex_codes.push(0b0_000001_000000010);         
                        }
                        "C" => {
                          hex_codes.push(0b0_000001_000000001);         
                        }
                        
                        i if i.starts_with("#") =>  {
                            let digit = u16::from_str_radix(&i[1..], 10).expect("not a valid number");
                            hex_codes.push(0b1_000001_010000000);         
                            hex_codes.push(digit);
                        }

                        _ => {
                            panic!("invalid ADD command");
                        }
                    }
                }
                "STA" => {
                    match &REG[..] {
                        "A" => {
                          hex_codes.push(0b0_000010_000001000);         
                        }
                        "B" => {
                          hex_codes.push(0b0_000010_000000100);         
                        }
                        "C" => {
                          hex_codes.push(0b0_000010_000000010);         
                        }
                        "LED" => {
                          hex_codes.push(0b0_000010_000000001);         
                        }
                        _ => {
                           panic!("{} Register doesn't exist", REG);
                        }
                    }
                }
                "INV" => {
                    match &REG[..] {
                        "A" => {
                          hex_codes.push(0b0_000011_000001000);         
                        }
                        "B" => {
                          hex_codes.push(0b0_000011_000000100);         
                        }
                        "C" => {
                          hex_codes.push(0b0_000011_000000010);         
                        }
                        "AC" => {
                          hex_codes.push(0b0_000011_000000001);         
                        }
                        _ => {
                           panic!("{} Register doesn't exist", REG);
                        }
                    }
                }
                "PRNT" => {
                }

                _ => {
                    panic!("unknown OPCODE on line {}", i);
                }
            }
        },

            [] => {}

            [..] => {
                panic!("unexpected Instruction on line {}", i);
            }
        }
    }

    println!("{:?}", tokenized_form);

    println!("{:?}", hex_codes);

    let mut new_file = OpenOptions::new()
        .create(true)
        .write(true)
        .open(path.with_file_name(path.file_stem().unwrap()))
        .expect("no file");

    writeln!(&mut new_file, "v2.0 raw");

    for (i, hex) in hex_codes.iter().enumerate() {
        write!(&mut new_file, "{:x}", hex);

        if (i + 1) % 2 == 0 {
            write!(&mut new_file, " ");
        }
    }
}
