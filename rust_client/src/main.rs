use numbers::Numbers;
mod numbers;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let method = std::env::args().nth(1).expect("no method given");
    let url = std::env::args().nth(2).expect("no url given");
    let client = reqwest::blocking::Client::new();

     match method.as_str() {
        "GET" => Numbers::list(client.get(&url).send()?.json()?, &std::io::stdout()),
        "POST" => println!("{}", client.post(&url).send()?.text()?),
        &_ => todo!()
    };
    
    Ok(())
}

