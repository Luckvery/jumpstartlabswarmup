class Encryptor

  def supported_chaacters
    (' '..'z').to_a
  end

  def crack(message)
    supported_chaacters.count.times.collect do |attempt|
      decrypt(message, attempt)
    end
  end

  def cipher(rotation)
     characters = (' '..'z').to_a
     rotated_characters = characters.rotate(rotation)
     Hash[characters.zip(rotated_characters)]
  end

  def encrypt(string, rotation)
    convert(action: "encrypt" , phrase: string, rotation: rotation)
  end

  def decrypt(string, rotation)
    convert(action: "decrypt", phrase: string, rotation: rotation)
  end
  
  def convert(params)
    values_to_rotate_through = (params[:rotation]..(params[:rotation]+3)).to_a
    phrase_array =  params[:phrase].split("")

    results =phrase_array.each_with_index.collect do |letter, index|
      puts values_to_rotate_through.first
      values_to_rotate_through.rotate(index)

      if(params[:action] == "encrypt")
        encrypt_letter(letter, values_to_rotate_through.first) 
      elsif (params[:action] == "decrypt")
        decrypt_letter(letter, values_to_rotate_through.first)
      end
   
    end
    results.join
  end

  def decrypt_letter(letter, rotation)
   cipher_for_rotation = cipher(rotation)
   cipher_for_rotation.invert[letter]
  end

  def encrypt_letter(letter, rotation)
    cipher_for_rotation= cipher(rotation)
    cipher_for_rotation[letter]
  end

  def encrypt_file(filename, rotation)
    #Create the file handle to the input file
    file =  File.open(filename, "r")

    #Read the text of the input file
    message = file.read
    file.close

    #Encrypt the text
    encrypted_message = encrypt(message, rotation)

    #Create a name for the output file
    encrypted_filename = filename + ".encrypted"    
  
    #Write out the text
    file =  File.open(encrypted_filename, "w")
    file.write (encrypted_message)
   
    #Close file
    file.close

  end

  def decrypt_file(filename, rotation)
    #Create the file handle to the input file
    file =  File.open(filename, "r")

    #Read the text of the input file
    message = file.read
    file.close

    #Encrypt the text
    decrypted_message = decrypt(message, rotation)

    #Create a name for the output file
    decrypted_filename = filename.gsub(".txt.encrypted" , ".decrypted.txt")
  
    #Write out the text
    file =  File.open(decrypted_filename, "w")
    file.write (decrypted_message)
   
    #Close file
    file.close

  end
end
