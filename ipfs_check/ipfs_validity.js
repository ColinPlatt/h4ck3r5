const axios = require('axios');
const validUrl = require('valid-url');

async function checkImageLink() {

    let validCount = 0;
    let invalidCount = 0;

    for(let i = 1; i <= 1507; i++) {
        let url = `https://bafybeicnoxjorayfx2e3udo7gbbi2ab6j6bdc3yi4vhbrbpkz7fzqiimdu.ipfs.nftstorage.link/${i}`;
        try {
            let response = await axios.get(url);
            if(response.status === 200) {
                let data = response.data;
                if(data.image && validUrl.isUri(data.image)) {
                    console.log(`Image URL in ${i} is valid: ${data.image}`);
                    validCount++;
                } else {
                    console.log(`Image URL in ${i} is not valid or doesn't exist`);
                    invalidCount++;
                }
            }
        } catch (error) {
            console.error(`Failed to fetch ${i}: ${error}`);
        }
    }

    console.log(`Valid image URLs: ${validCount}`);
    console.log(`Invalid image URLs: ${invalidCount}`);
}

checkImageLink();
